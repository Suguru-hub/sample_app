require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)   # test/fixtures/users.yml参照
  end

  # 編集の失敗に対するテスト
  test "unsuccessful edit" do
    log_in_as(@user)               # users_controllerにbefore_action追加したので追加
    get edit_user_path(@user)      # 編集ページにアクセス
    assert_template 'users/edit'   # editビューが描画されるかチェック
    patch user_path(@user),        # patchリクエストで無効なユーザー情報送信
    params: {
      user: {
        name:                  "",
        email:                 "foo@invalid",
        password:              "foo",
        password_confirmation: "bar"
      }
    }
    assert_template 'users/edit'   # editビューが再描画されるかチェック
    # assert_select使い方 https://qiita.com/shumpeism/items/06332cb4ced1c15cb09c
    assert_select 'div.alert', 'The form contains 4 errors.'   # 正しいエラーメッセージが表示されているか
  end

  # 編集の成功に対するテスト
  # フレンドリーフォワーディング(ログインしていないユーザーが編集ページにアクセス→
  # ログインページに飛ばされてログイン→親切に編集ページに飛ばしてあげたい)のテスト
  test "successful edit with friendly forwarding" do
    get edit_user_path(@user)
    assert_equal edit_user_url(@user), session[:forwarding_url]
    log_in_as(@user)
    assert_redirected_to edit_user_url(@user)
    assert_nil(session[:forwarding_url])
    name = "Foo Bar"
    email = "foo@bar.com"
    patch user_path(@user),
      params: {
        user: {
          name: name,
          email: email,
          password: "",
          password_confirmation: ""
        }
      }
    assert_not flash.empty?
    assert_redirected_to @user
    @user.reload   # DBから最新のユーザー情報を読み込みなおす
    assert_equal name, @user.name
    assert_equal email, @user.email
  end

end
