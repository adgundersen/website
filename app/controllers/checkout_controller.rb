class CheckoutController < ApplicationController
  skip_before_action :verify_authenticity_token, only: [:webhook]

  def create_session
    session = Stripe::Checkout::Session.create(
      mode: "subscription",
      line_items: [{ price: ENV.fetch("STRIPE_PRICE_ID"), quantity: 1 }],
      success_url: "#{ENV.fetch("BASE_URL")}/dashboard?session_id={CHECKOUT_SESSION_ID}",
      cancel_url:  "#{ENV.fetch("BASE_URL")}/",
    )
    render json: { url: session.url }
  rescue Stripe::StripeError => e
    render json: { error: e.message }, status: :bad_request
  end

  def webhook
    payload    = request.body.read
    sig_header = request.headers["HTTP_STRIPE_SIGNATURE"]

    event = Stripe::Webhook.construct_event(
      payload, sig_header, ENV.fetch("STRIPE_WEBHOOK_SECRET")
    )

    if event["type"] == "checkout.session.completed"
      sess = event["data"]["object"]

      uri  = URI("#{ENV.fetch("INFRA_SERVICE_URL")}/instances")
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = uri.scheme == "https"
      req  = Net::HTTP::Post.new(uri.path, "Content-Type" => "application/json")
      req.body = {
        stripe_customer_id:     sess["customer"],
        stripe_subscription_id: sess["subscription"],
        email:                  sess.dig("customer_details", "email")
      }.to_json
      res = http.request(req)

      body = JSON.parse(res.body)
      Customer.find_or_create_by(stripe_customer_id: sess["customer"]) do |c|
        c.stripe_subscription_id = sess["subscription"]
        c.email                  = sess.dig("customer_details", "email")
        c.slug                   = body["slug"]
        c.status                 = body["status"] || "provisioning"
      end
    end

    render json: { status: "ok" }
  rescue Stripe::SignatureVerificationError
    render json: { error: "invalid signature" }, status: :bad_request
  end
end
