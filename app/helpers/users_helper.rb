module UsersHelper
    # 引数で与えられたユーザーのGravatar画像を返す
    # optionsでサイズも指定できるよ
    # Gravatarとは：https://www.adminweb.jp/wordpress/comment/index10.html
  def gravatar_for(user, options = {size: 80})
    # MD5という仕組みでユーザのメアドをハッシュ化
    gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
    size = options[:size]
    gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
    image_tag(gravatar_url, alt: user.name, class: "gravatar")
  end
end
