# パスワード再設定の統合テスト

require 'test_helper'

class PasswordResetsTest < ActionDispatch::IntegrationTest
  
  def setup
    ActionMailer::Base.deliveries.clear
    @user = users(:michael)
  end

  test "password resets" do
    ### 「forgot password」フォームを表示。メアドを入力する画面。
    get new_password_reset_path
    assert_template 'password_resets/new'

    # 無効なメアドを入力したとき
    post password_resets_path, params: {password_reset: {email: ""}}
    assert_not flash.empty?
    assert_template 'password_resets/new'

    # 有効なメアドを入力したとき
    post password_resets_path,
         params: {password_reset: {email: @user.email}}
    assert_not_equal @user.reset_digest, @user.reload.reset_digest  # ダイジェストがちゃんと変わっているか
    assert_equal 1, ActionMailer::Base.deliveries.size
    assert_not flash.empty?
    assert_redirected_to root_url

    ### パスワード再設定フォームのテスト
    user = assigns(:user)  # assignsはcontrollerの中で定義されたインスタンス変数を参照するもの。変数名をシンボルで渡す。

    # 無効なメアドのユーザーがパスワード入力画面にアクセスしたとき(beforeフィルタが正しく動くか)
    get edit_password_reset_path(user.reset_token, email: "")
    assert_redirected_to root_url

    # 有効化されていないユーザーがアクセスしたとき(beforeフィルタが正しく動くか)
    user.toggle!(:activated)  # toggleメソッドはboolean型の属性名のシンボルを渡すと、値を反転してsaveする
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_redirected_to root_url
    user.toggle!(:activated)  # 元の値に戻す

    # メアドが有効だが、トークンが無効なユーザーがアクセスしたとき
    get edit_password_reset_path('wrong token', email: user.email)
    assert_redirected_to root_url

    # メアドもトークンも有効なユーザーがアクセスしたとき
    get edit_password_reset_path(user.reset_token, email: user.email)
    assert_template 'password_resets/edit'
    assert_select "input[name=email][type=hidden][value=?]", user.email  # <input id="email" name="email" type="hidden" value="michael@example.com" />

    # 無効なパスワードとパスワード確認を入力したとき
    patch password_reset_path(user.reset_token),
          params: {email: user.email,
                   user:  {password:              "foobaz",
                           password_confirmation: "barquux"}}
    assert_select 'div#error_explanation'

    # パスワードが空で入力したとき
    patch password_reset_path(user.reset_token),
          params: {email: user.email,
                   user:  {password:              "",
                           password_confirmation: ""}}
    assert_select 'div#error_explanation'

    # 有効なパスワードとパスワード確認を入力したとき
    patch password_reset_path(user.reset_token),
          params: {email: user.email,
                   user:  {password:              "foobaz",
                           password_confirmation: "foobaz"}}
    assert is_logged_in?
    assert_not flash.empty?
    assert_redirected_to user
  end
end
