SecureSocialMediaSystem::Application.routes.draw do
  
  post "friendlistentries/remotedestroy" => "friendlistentries#remote_destroy"
  post "friendlistentries/remoteconfirm" => "friendlistentries#remote_confirm"
  post "friendlistentries/remotecreate" => "friendlistentries#remote_create"
  get "confirmrequest/:id" => "friendlistentries#confirmrequest", as: "confirm_friend_request"
  get "friendlistentries/:id/edit" => "friendlistentries#edit", as: "edit_friendlistentry"
  get "friendlistentries" => "friendlistentries#index", as: "friends"
  resources :friendlistentries

  
  get"guestbookentries/new/:id" => "guestbookentries#new", as: "new_guestbookentry"
  get "guestbookentries/:id" => "guestbookentries#destroy", as: "delete_guestbookentry"
  get "guestbookentries" => "profiles#show"
  resources :guestbookentries

  post "messages/remotedestroy" => "messages#remote_destroy"
  post "messages/remotecreate" => "messages#remote_create"
  get "messages" => "messages#index", as: "messages_overview"
  resources :messages

  get "profiles/new", as: "new_profile"
  get "profiles/edit", as: "profile_edit"
  put "profiles" => "profiles#update", as: "profile_update"
  #get "profiles/:id" => "profiles#show", as: "profile"
  get "profiles/:email" => "profiles#show", as: "profile"
  get "profiles" => "profiles#show", as: "my_profile"
  resources :profiles

  #get "home/new"

  get "log_out" => "sessions#destroy", :as => "log_out"
  get "log_in" => "sessions#new", :as => "log_in"
  get "sign_up" => "users#new", :as => "sign_up"
  root :to => "home#index"
  
  get "users/index" => "users#index"
  resources :users
  
  
  post "sessions/remotecreate" => "sessions#remote_create"
  resources :sessions
  
  get "pages" => "pages#show"
  resources :pages
  
  
  resources :home


  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
