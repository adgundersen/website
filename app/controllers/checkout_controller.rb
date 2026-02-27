require "net/http"
require "uri"
require "json"

class CheckoutController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]
  before_action :require_auth, only: [:start]

  # GET /checkout/start — create Stripe session and redirect
  def start
    # Already subscribed — send to dashboard
    if current_customer.subscribed?
      return redirect_to dashboard_path
    end

    stripe_session = Stripe::Checkout::Session.create(
      customer_email: current_customer.email,
      mode:           "subscription",
      line_items:     [{ price: ENV.fetch("STRIPE_PRICE_ID"), quantity: 1 }],
      success_url:    "#{ENV.fetch("BASE_URL")}/dashboard",
      cancel_url:     "#{ENV.fetch("BASE_URL")}/pricing",
      metadata:       { customer_id: current_customer.id }
    )

    redirect_to stripe_session.url, allow_other_host: true
  rescue Stripe::StripeError => e
    redirect_to pricing_path, alert: e.message
  end

  # POST /checkout/webhook
  def webhook
    payload    = request.body.read
    sig_header = request.headers["HTTP_STRIPE_SIGNATURE"]

    event = Stripe::Webhook.construct_event(
      payload, sig_header, ENV.fetch("STRIPE_WEBHOOK_SECRET")
    )

    if event["type"] == "checkout.session.completed"
      sess = event["data"]["object"]

      # Find the customer we created at signup via metadata
      customer  = Customer.find_by(id: sess.dig("metadata", "customer_id"))
      customer ||= Customer.find_by(email: sess.dig("customer_details", "email"))

      return render json: { status: "ok" } unless customer

      uri  = URI("#{ENV.fetch("INFRA_SERVICE_URL")}/instances")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      req  = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      req.body = {
        stripe_customer_id:     sess["customer"],
        stripe_subscription_id: sess["subscription"],
        email:                  customer.email
      }.to_json
      res  = http.request(req)
      body = JSON.parse(res.body)

      customer.update!(
        stripe_customer_id:     sess["customer"],
        stripe_subscription_id: sess["subscription"],
        slug:                   body["slug"],
        status:                 body["status"] || "provisioning"
      )
    end

    render json: { status: "ok" }
  rescue Stripe::SignatureVerificationError
    render json: { error: "invalid signature" }, status: :bad_request
  end
end
