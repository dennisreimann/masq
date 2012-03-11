Rails.application.routes.draw do
  mount Masq::Engine => "/masq"
  get "/*account" => "masq/accounts#show", :as => :identity
  root :to => "masq/info#index"
end
