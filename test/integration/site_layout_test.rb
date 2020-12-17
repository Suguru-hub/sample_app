require 'test_helper'
# 統合テスト
# https://railsguides.jp/testing.html#%E3%83%93%E3%83%A5%E3%83%BC%E3%82%92%E3%83%86%E3%82%B9%E3%83%88%E3%81%99%E3%82%8B
class SiteLayoutTest < ActionDispatch::IntegrationTest
  # Home、Help、About、Contactの各ページへのリンクが正しく動くかテスト
  # 指定したリンクがちゃんとビューに存在するかどうか見てるんやろうな
  test "layout links" do
    get root_path
    assert_template 'static_pages/home'
    # ?はroot_pathに置換される。ここではリンクの個数も調べている(ロゴとナビゲーションバー)
    # assert_selectメソッドには多くのオプションが存在する
    assert_select "a[href=?]", root_path, count: 2
    assert_select "a[href=?]", help_path
    assert_select "a[href=?]", about_path
    assert_select "a[href=?]", contact_path
  end
end
