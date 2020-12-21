require 'test_helper'

# 以下で作りました
# https://railstutorial.jp/chapters/filling_in_the_layout?version=5.1#sec-exercises_layout_link_tests
class ApplicationHelperTest < ActionView::TestCase
  test "full title helper" do
    assert_equal full_title,         "Ruby on Rails Tutorial Sample App"
    assert_equal full_title("Help"), "Help | Ruby on Rails Tutorial Sample App"
  end
end