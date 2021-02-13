# 永続的セッションのテスト
# current_userの複雑な分岐処理をテストする
# テスト手順はシンプルです。

# 1. fixtureでuser変数を定義する
# 2. 渡されたユーザーをrememberメソッドで記憶する
# 3. current_userが、渡されたユーザーと同じであることを確認します

# ユーザーの記憶ダイジェストが記憶トークンと正しく対応していない場合のテストも追加

require 'test_helper'

class SessionsHelperTest < ActionView::TestCase

  def setup
    @user = users(:michael)   # fixture
    remember(@user)
  end

  test "current_user returns right user when session is nil" do
    assert_equal @user, current_user
    assert is_logged_in?
  end

  test "current_user returns nil when remember digest is wrong" do
    @user.update_attribute(:remember_digest, User.digest(User.new_token))
    assert_nil current_user
  end
end