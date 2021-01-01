require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
  end

  test "should be valid" do
    # @userオブジェクトが有効かどうか(valid?メソッド。Userモデルにバリデーションがない段階ではテストは成功するはず)
    # valid?メソッドはモデルのすべてのバリデーションに通った時にtrueを返す
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = "  "
    assert_not @user.valid?  # オブジェクトが有効でなければ成功
  end

  test "email should be present" do
    @user.email = " "
    assert_not @user.valid?
  end

  # 文字列の長さの検証
  test "name should not be too long" do
    @user.name = "a" * 51   # バリデーションで50を上限としたから51で検証
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com" # バリデーションで255を上限としたから256で検証
    assert_not @user.valid?
  end
end
