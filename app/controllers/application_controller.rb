class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  # Sessionヘルパーを読み込む
  include SessionsHelper
end
