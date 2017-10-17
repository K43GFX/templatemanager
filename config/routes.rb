Rails.application.routes.draw do
  
  #scope "/templatemanager"  || "/" do
  devise_for :users
  resources :activities
  resources :settings
  resources :errors
  resources :snapshots

  # Route for API error(s)
  get 'error/api_not_found'

  # Routes to Setup views
  get 'setup', :to => 'setup#index'
  get 'setup/api', :to => 'setup#apisetup'
  get 'setup/rdp', :to => 'setup#rdpsetup'
  get 'setup/done', :to => 'setup#finalized'
  get 'setup/master', :to => 'setup#createmaster'
  get 'setup/locked', :to => 'setup#locked'

  post 'snapshots/new_snapshot', :to => 'snapshots#new_snapshot'
  delete 'snapshots/destroymultiple', :to => 'snapshots#destroymultiple'
  # Routes for Setup actions
  patch 'setup/rdp', :to => 'setup#rdpinitialize'
  patch 'setup/master', :to => 'setup#masterinitialize'
  post 'setup/master', :to => 'setup#masterinitialize'
  patch 'setup/api', :to => 'setup#apiupdate'
  patch 'setup/lock', :to => 'setup#lock'

  post 'machines/no_functionality', :to => 'machines#no_functionality'
  post 'machines/refresh_dashboard_vm', :to => 'machines#refresh_dashboard_vm'
  resources :machines

  root 'machines#index'
put 'setstate/:id(.:format)', :to => 'machines#setstate', :as => :set_machine_state
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
#end
