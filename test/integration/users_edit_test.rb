require 'test_helper'

class UsersEditTest < ActionDispatch::IntegrationTest
  
  def setup
    @user = users(:michael)   # test/fixtures/users.yml参照
  end

  # 編集の失敗に対するテスト
  test "unsuccessful edit" do
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
    assert_select 'div.alert', count: 4   # 正しい数のエラーメッセージが表示されているか
  end

end
