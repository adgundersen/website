class SessionsController < ApplicationController
  def new
    redirect_to dashboard_path if current_customer
  end

  def create
    email = params[:email].to_s.strip.downcase

    unless email.match?(URI::MailTo::EMAIL_REGEXP)
      flash.now[:alert] = "Please enter a valid email address."
      return render :new, status: :unprocessable_entity
    end

    customer = Customer.find_or_initialize_by(email: email)
    customer.generate_magic_token!

    CustomerMailer.magic_link(customer).deliver_now

    # In development, log the link so you don't need a real email service
    if Rails.env.development?
      Rails.logger.info "MAGIC LINK: #{verify_url(token: customer.magic_token)}"
    end

    redirect_to login_sent_path
  end

  def sent
  end

  def verify
    customer = Customer.find_by(magic_token: params[:token])

    if customer.nil? || !customer.magic_token_valid?
      flash[:alert] = "That link has expired or is invalid. Request a new one."
      return redirect_to login_path
    end

    customer.verify_email!
    session[:customer_id] = customer.id

    redirect_after_auth
  end

  def destroy
    session.delete(:customer_id)
    redirect_to root_path
  end
end
