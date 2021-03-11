require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

  # 失敗時のテスト
  test "invalid signup information" do
    get signup_path
    # テストの前後でUser.countの値に差(difference)がないか(下記の不正なユーザが登録されていないこと)をチェック
    assert_no_difference 'User.count' do
      # すべての値が不正なuserオブジェクトをuser#createに送信
      post signup_path, params: { user: { name:  "",
                                         email: "user@invalid",
                                         password:              "foo",
                                         password_confirmation: "bar" } }
    end
    # 指定されたテンプレート(new.html.erb)が選択されたか
    assert_template 'users/new'
    # 適切なエラーメッセージが表示されているか
    assert_select "li", "Name can't be blank"
    assert_select "li", "Email is invalid"
    assert_select "li", "Password confirmation doesn't match Password"
    assert_select "li", "Password is too short (minimum is 6 characters)"
    # assert_selectの使い方：https://qiita.com/shumpeism/items/06332cb4ced1c15cb09c
    
    # 下記アサートを書いた意味は演習４参照（下記リンク先のちょっと上にあるよ）
    # https://railstutorial.jp/chapters/sign_up?version=5.1#code-post_signup_form
    assert_select 'form[action="/signup"]'
  end

  # 有効なユーザー登録に対するテスト
  test "valid signup information" do
    get signup_path
    # テストの前後でUser.countの値に1の差(第二引数)があるか(下記のユーザが登録されていること)をチェック
    assert_difference 'User.count', 1 do
      post users_path, params: { user: { name:  "Example User",
                                         email: "user@example.com",
                                         password:              "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!              # リクエストを送信した結果を見て、指定されたリダイレクト先に移動する
    # assert_template 'users/show'  # ↑の結果、users/showテンプレートが表示されているかチェック
    # assert is_logged_in?          # サインアップ後、そのままログインできているか
  end
end