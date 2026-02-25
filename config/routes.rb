Rails.application.routes.draw do
  root "pages#home"
  get  "/pricing",  to: "pages#pricing"
  get  "/success",  to: "pages#success"

  post "/checkout/create_session", to: "checkout#create_session"
  post "/checkout/webhook",        to: "checkout#webhook"

  get "up" => "rails/health#show", as: :rails_health_check
end
