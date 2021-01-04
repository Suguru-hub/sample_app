class User < ApplicationRecord
    # ユーザをDBに保存する前にemailを小文字に変換
    # いくつかのDBのアダプタが、常に大文字小文字を区別するインデックスを使っているとは限らない問題への対処
    # Userモデルの中では右式のselfを省略できるらしい(左式は省略不可)
    # 直接値を更新できるdowncase!メソッドを使って以下のようにしてもいいね
    # before_save {email.downcase!}
    before_save {self.email = email.downcase}
    validates :name, presence: true, length: {maximum: 50}
    # email用の正規表現を定数変数に格納
    # この正規表現の詳しい意味：https://railstutorial.jp/chapters/modeling_users?version=5.1#table-valid_email_regex
    # Ruby正規表現リファレンスマニュアル：https://docs.ruby-lang.org/ja/latest/doc/spec=2fregexp.html
    # 以下の正規表現は、foo@bar..comのようなドットの連続を誤りとして検出できるように修正してある
    VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-]+(\.[a-z\d\-]+)*\.[a-z]+\z/i
    validates :email, presence: true, length: {maximum: 255},
                format: {with: VALID_EMAIL_REGEX},  # 正規表現のバリデーション
                uniqueness: {case_sensitive: false}
end
