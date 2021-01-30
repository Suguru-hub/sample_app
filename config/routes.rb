Rails.application.routes.draw do
  root 'static_pages#home'
  get  '/help',    to: 'static_pages#help'  # help_pathという名前付きルートができる
  get  '/about',   to: 'static_pages#about'
  get  '/contact', to: 'static_pages#contact'
  get  '/signup',  to: 'users#new'     # signup_path
  
  # resources :usersがあるのに、下記routingを書いた意味は演習2参照（下記リンク先のちょっと上にあるよ）
  # 検索バーの表示URLの気持ち悪さ解消のためだね。ざっくりいうと。
  # https://railstutorial.jp/chapters/sign_up?version=5.1#code-post_signup
  post '/signup',  to: 'users#create'  # signup_path

  get    '/login',   to: 'sessions#new'
  post   '/login',   to: 'sessions#create'
  delete '/logout',  to: 'sessions#destroy'


  # RESTfulなusersリソースで必要となるすべてのアクションが利用できるようになる。
  # 詳しくは以下参照
  # https://railstutorial.jp/chapters/sign_up?version=5.1#table-RESTful_users
  # こちらもどうぞ：https://railsguides.jp/routing.html#crud%E3%80%81%E5%8B%95%E8%A9%9E%E3%80%81%E3%82%A2%E3%82%AF%E3%82%B7%E3%83%A7%E3%83%B3
  resources :users


end