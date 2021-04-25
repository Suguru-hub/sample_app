require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
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

  # 重複するメアド拒否のテスト(uniquenessバリデーションのチェック)
  test "email addresses should be unique" do
    # dupメソッドはオブジェクトのコピーを作成する:https://www.sejuku.net/blog/76564
    duplicate_user = @user.dup
    duplicate_user.email = @user.email.upcase  # 大文字にしてもちゃんとはじいてくれるか(大文字小文字を区別しないようにしているので)
    @user.save
    # @user保存後では、複製されたユーザーのメアドが既にDB内に存在するため、重複したメアドのユーザの作成は無効になるはず
    assert_not duplicate_user.valid?
  end

  # db保存前にemailを小文字に変換する機能がちゃんと機能しているかチェック
  # 機能はuser.rb見ればわかるよ
  test "email addresses should be saved as lower-case" do
    mixed_case_email = "Foo@ExAMPle.CoM"
    @user.email = mixed_case_email
    @user.save
    # 値が一致しているかどうか確認
    # reloadメソッドは、DBの値に合わせて値を更新するメソッド
    assert_equal mixed_case_email.downcase, @user.reload.email
  end

  # passwordが空の時ちゃんとはじいてくれるかどうか
  test "password should be present (nonblank)" do
    # passwordとpassword_confirmationに対して同時に代入(多重代入)
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  # passwordの長さが最小文字数(6文字に設定した)に満たない場合、ちゃんとはじいてくれるかどうか
  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil remember_digest" do
    assert_not @user.authenticated?(:remember, '')
  end

  # Userモデルのdependent: :destroyのテスト
  test "associated microposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do  # ユーザー削除後、そのマイクロポストも削除されているか
      @user.destroy
    end
  end
end
