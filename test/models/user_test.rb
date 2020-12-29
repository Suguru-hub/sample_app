require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
  end

  test "should be valid" do
    # @userオブジェクトが有効かどうか(valid?メソッド。Userモデルにバリデーションがない段階ではテストは成功するはず)
    assert @user.valid?
  end
end
