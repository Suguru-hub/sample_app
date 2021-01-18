module UsersHelper
    # 引数で与えられたユーザーのGravatar画像を返す
    # Gravatarとは：https://www.adminweb.jp/wordpress/comment/index10.html
  def gravatar_for(user)
    # MD5という仕組みでユーザのメアドをハッシュ化
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
