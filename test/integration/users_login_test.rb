require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    # テストフィクスチャ(test/fixtures/users.yml 参照)
    @user = users(:michael)
  end

  test "login with invalid information" do
    # ログインページを開く
    get login_path
    # ログインページのフォームが表示されたことを確認
    assert_template 'sessions/new'
    # 無効なparamsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: {session: {email: "", password: ""}}
    # フォームが再度表示されたことを確認
    assert_template 'sessions/new'
    # フラッシュメッセージが追加されていることを確認
    assert_not flash.empty?
    # 別のページ（Homeページ）に移動する
    get root_path
    # 移動先のページでフラッシュメッセージが表示されていないことを確認
    assert flash.empty?
  end

  test "login with valid information followed by logout" do
    # ログインページを開く
    get login_path
    # 有効なparamsハッシュを使ってセッション用パスにPOSTする
    post login_path, params: {session: {email: @user.email, password: 'password'}}
    # ログインしているかチェック
    assert is_logged_in?
    # リダイレクト先が正しいかをチェック
    assert_redirected_to @user
    # リダイレクト先に実際に移動する
    follow_redirect!
    assert_template 'users/show'
    # ログインパスのリンクがページにない(count: 0)ことをチェック
    assert_select "a[href=?]", login_path, count: 0
    # ログアウトパスのリンクがページにあることをチェック
    assert_select "a[href=?]", logout_path
    # プロフィール用リンクがページにあることをチェック
    # user_pathとは：https://qiita.com/rentalgambler/items/219817842779fcf3d905
    assert_select "a[href=?]", user_path(@user)

    # ログアウト処理のチェック
    delete logout_path
    assert_not is_logged_in?
    assert_redirected_to root_url
    follow_redirect!
    assert_select "a[href=?]", login_path
    assert_select "a[href=?]", logout_path,      count: 0
    assert_select "a[href=?]", user_path(@user), count: 0
  end
end
