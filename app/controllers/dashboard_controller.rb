class DashboardController < ApplicationController
  before_action :require_auth

  def show
    @customer = current_customer
  end
end
