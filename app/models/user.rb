class User < ApplicationRecord
    attr_accessor :remember_token

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

    # has_secure_passwordによって以下のことが可能になる(Userテーブルにpassword_digestカラムを追加しておくのを忘れずに)
    # ・セキュアにハッシュ化したパスワードを、DB内のpassword_digestという属性に保存できるようになる。
    # ・2つのペアの仮想的な属性 (passwordとpassword_confirmation) が使えるようになる。また、存在性と値が一致するかどうかのバリデーションも追加される。
    # ・authenticateメソッドが使えるようになる (引数の文字列がpasswordと一致するとUserオブジェクトを、間違っているとfalseを返すメソッド) 。
    # また、has_secure_passwordを使ってパスワードをハッシュ化するためには、最先端のハッシュ関数であるbcryptが必要。
    # bcryptを使うためには、bcrypt gemをGemfileに追加し、bundle install
    # https://railstutorial.jp/chapters/modeling_users?version=5.1#code-bcrypt_ruby
    has_secure_password
    validates :password, presence: true, length: {minimum: 6}

    # 渡された文字列のハッシュ値を返す
    def User.digest(string)
        cost = ActiveModel::SecurePassword.min_cost ? BCrypt::Engine::MIN_COST :
                                                    BCrypt::Engine.cost
        BCrypt::Password.create(string, cost: cost)
    end

    # ランダムなトークンを返す
    def User.new_token
        SecureRandom.urlsafe_base64
    end

    # 永続セッションのためにユーザーをデータベースに記憶する
    def remember
        self.remember_token = User.new_token
        # DBのモデルのテーブルの対応レコードのremember_digestカラムの値を第二引数の値に更新
        # バリデーションは無視して更新される。（不正な値でも更新できる）
        update_attribute(:remember_digest, User.digest(remember_token))
    end
end
