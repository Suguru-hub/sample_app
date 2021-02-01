require 'test_helper'

class UsersLoginTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

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
end
