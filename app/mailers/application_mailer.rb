class ApplicationMailer < ActionMailer::Base
  default from: ENV.fetch("MAILER_FROM", "hello@crimata.com")
  layout "mailer"
end
