class ApplicationController < ActionController::Base
  helper_method :current_customer

  private

  def current_customer
    @current_customer ||= Customer.find_by(id: session[:customer_id])
  end

  def require_auth
    unless current_customer
      session[:return_to] = request.fullpath
      redirect_to login_path
    end
  end

  def redirect_after_auth
    path = session.delete(:return_to) || root_path
    redirect_to path
  end
end
