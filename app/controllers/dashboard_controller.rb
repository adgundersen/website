class DashboardController < ApplicationController
  def show
    if params[:session_id].present?
      stripe_session = Stripe::Checkout::Session.retrieve(params[:session_id])
      @customer = Customer.find_by(stripe_customer_id: stripe_session.customer)
    elsif params[:email].present?
      @customer = Customer.find_by(email: params[:email])
    else
      redirect_to root_path
    end
  rescue Stripe::StripeError
    redirect_to root_path
  end
end
