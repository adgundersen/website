class CustomerMailer < ApplicationMailer
  def magic_link(customer)
    @customer = customer
    @url      = verify_url(token: customer.magic_token)
    @expires  = "15 minutes"

    mail(to: @customer.email, subject: "Your Crimata sign-in link")
  end
end
