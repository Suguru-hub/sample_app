require 'test_helper'

class UsersActivationTest < ActionDispatch::IntegrationTest
  # test "the truth" do
  #   assert true
  # end

  def setup
    @activated_user     = users(:michael)
    @non_activated_user = users(:red)
  end

  # ユーザー一覧(/users)に表示されているのはアカウント有効化されているユーザーのみか
  test "index only activated user" do
    log_in_as(@activated_user)
    get users_path
    assert_select "a[href=?]", user_path(@activated_user)
    assert_select "a[href=?]", user_path(@non_activated_user), count: 0
  end

  # 詳細ページ(/users/:id)にアクセスできるのは有効化されているユーザーのみか
  test "show only activated user" do
    log_in_as(@activated_user)
    get user_path(@activated_user)
    assert_template 'users/show'

    # 有効化されていないユーザーの詳細ページにアクセスしようとすると、ルートページに飛ばされるか
    get user_path(@non_activated_user)
    assert_redirected_to root_url
  end
end
