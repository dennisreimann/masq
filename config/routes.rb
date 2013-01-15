Masq::Engine.routes.draw do
  resource :account do
    get :activate
    get :password
    put :change_password

    resources :personas
    resources :sites
    resource :yubikey_association, :only => [:create, :destroy]
  end

  resource :password
  resource :session, :only => [:new, :create, :destroy]

  get "/help" => "info#help", :as => :help
  get "/safe-login" => "info#safe_login", :as => :safe_login

  get "/forgot_password" => "passwords#new", :as => :forgot_password
  get "/reset_password/:id" => "passwords#edit", :as => :reset_password

  get "/login" => "sessions#new", :as => :login
  get "/logout" => "sessions#destroy", :as => :logout
  post '/resend_activation_email/*account' => 'accounts#resend_activation_email', :as => :resend_activation_email

  match "/server" => "server#index", :as => :server, :via => [:get, :post]
  match "/server/decide" => "server#decide", :as => :decide, :via => [:get, :post]
  match "/server/proceed" => "server#proceed", :as => :proceed, :via => [:get, :post]
  match "/server/complete" => "server#complete", :as => :complete, :via => [:get, :post]
  match "/server/cancel" => "server#cancel", :as => :cancel, :via => [:get, :post]
  get "/server/seatbelt/config.:format" => "server#seatbelt_config", :as => :seatbelt_config
  get "/server/seatbelt/state.:format" => "server#seatbelt_login_state", :as => :seatbelt_state

  get "/consumer" => "consumer#index", :as => :consumer
  post "/consumer/start" => "consumer#start", :as => :consumer_start
  match "/consumer/complete" => "consumer#complete", :as => :consumer_complete, :via => [:get, :post]

  get "/*account" => "accounts#show", :as => :identity

  root :to => "info#index"
end
