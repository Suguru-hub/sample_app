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

  # 有効なメールアドレスの検証(emailの正規表現バリデーションが正しく機能しているか)
  test "email validation should accept valid addresses" do
    # %wについて：https://qiita.com/mogulla3/items/46bb876391be07921743#3-w
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      # assertメソッドの第2引数にエラーメッセージを追加している。こうすれば、どのメアドでテストが失敗したのかを特定できるよね
      # inspectメソッドは、オブジェクトや配列などをわかりやすく文字列で返してくれるメソッド
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end

  # 無効なメアドの検証(emailの正規表現バリデーションが正しく機能しているか)
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert_not @user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end
end
