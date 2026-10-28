Rails.application.routes.draw do
  root "pages#home"

  resource :session, only: %i[ new create destroy ]
  resource :registration, only: %i[ new create ]

  get "dashboard", to: "dashboard#index", as: :dashboard
  get "dashboard/export", to: "dashboard#export", as: :dashboard_export

  # Redirect to localhost from 127.0.0.1 to use same IP address with Vite server
  constraints(host: "127.0.0.1") do
    get "(*path)", to: redirect { |params, req| "#{req.protocol}localhost:#{req.port}/#{params[:path]}" }
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  get "up" => "rails/health#show", as: :rails_health_check
end
