ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rails/test_help'

class ActiveSupport::TestCase
  # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
  fixtures :all

  # Add more helper methods to be used by all tests here...
  include ApplicationHelper

  # テストユーザーがログイン中の場合にtrueを返す
  def is_logged_in?
    !session[:user_id].nil?
  end

  # テストユーザーとしてログインする(テスト用のログインメソッド)
  def log_in_as(user)
    session[:user_id] = user.id
  end
end

class ActionDispatch::IntegrationTest

  # テストユーザーとしてログインする(統合テスト用のログインメソッド)
  # 統合テストではsessionを直接取り扱うことができないので、
  # 代わりにSessionsリソースに対してpostを送信することでログイン
  # passwordと[remember_me]チェックボックスの値にはデフォルト値を設定している
  def log_in_as(user, password: 'password', remember_me: '1')
    post login_path, params: {session: {email: user.email,
                                        password: password,
                                        remember_me: remember_me}}
  end
end