Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'  # help_pathという名前付きルートができる
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'
  # RESTfulなusersリソースで必要となるすべてのアクションが利用できるようになる。
  # 詳しくは以下参照
  # https://railstutorial.jp/chapters/sign_up?version=5.1#table-RESTful_users
  resources :users
end