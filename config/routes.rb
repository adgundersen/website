Rails.application.routes.draw do
  root "pages#home"
  get  "/pricing", to: "pages#pricing"

  # Auth
  get    "/login",      to: "sessions#new",     as: :login
  post   "/login",      to: "sessions#create"
  get    "/login/sent", to: "sessions#sent",    as: :login_sent
  get    "/verify",     to: "sessions#verify",  as: :verify
  get    "/logout",     to: "sessions#destroy", as: :logout

  # Dashboard (requires auth)
  get "/dashboard", to: "dashboard#show"

  # Checkout
  get  "/checkout/start",   to: "checkout#start",   as: :checkout_start
  post "/checkout/webhook", to: "checkout#webhook"

  get "up" => "rails/health#show", as: :rails_health_check
end
