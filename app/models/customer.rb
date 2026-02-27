class Customer < ApplicationRecord
  TOKEN_TTL = 15.minutes

  def generate_magic_token!
    self.magic_token            = SecureRandom.urlsafe_base64(32)
    self.magic_token_expires_at = TOKEN_TTL.from_now
    save!
    magic_token
  end

  def magic_token_valid?
    magic_token.present? && magic_token_expires_at&.future?
  end

  def verify_email!
    update!(
      email_verified_at:      Time.current,
      magic_token:            nil,
      magic_token_expires_at: nil
    )
  end

  def email_verified?
    email_verified_at.present?
  end

  def subscribed?
    stripe_customer_id.present?
  end
end
