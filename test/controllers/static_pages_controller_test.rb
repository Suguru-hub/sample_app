require 'test_helper'

class StaticPagesControllerTest < ActionDispatch::IntegrationTest

#Homeページのテスト。
#GETリクエストをhomeアクションに対して発行 (=送信) せよ。
#そうすれば、リクエストに対するレスポンスは[成功]になるはず
  test "should get home" do
    get static_pages_home_url
    assert_response :success
  end

  test "should get help" do
    get static_pages_help_url
    assert_response :success
  end

  test "should get about" do
    get static_pages_about_url
    assert_response :success
  end
end
