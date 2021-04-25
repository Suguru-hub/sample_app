class User < ApplicationRecord
    # ユーザーがマイクロポストを複数所有する関連付け(後半のオプションによって、ユーザーが削除されれば、そのマイクロポストも削除される)
    has_many :microposts, dependent: :destroy

    # 仮の属性。DBのUserはこれらの値を実際には持っていない。
    attr_accessor :remember_token, :activation_token, :reset_token

    # ユーザをDBに保存する前にemailを小文字に変換
    # いくつかのDBのアダプタが、常に大文字小文字を区別するインデックスを使っているとは限らない問題への対処
    before_save   :downcase_email
    # ユーザーが作成される前に有効化トークンと有効化ダイジェストを作成
    before_create :create_activation_digest
    validates     :name, presence: true, length: {maximum: 50}
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

    # allow_nil: trueによって、パスワードが空でも更新できるようなる
    # ただし、これによって新規ユーザー登録時に空のパスワードが有効になってしまうことはない。
    # has_secure_passwordでは (追加したバリデーションとは別に) オブジェクト生成時に存在性を検証するようになっているため、
    # 空のパスワード (nil) が新規ユーザー登録時に有効になることはない。
    validates :password, presence: true, length: {minimum: 6}, allow_nil: true

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

    # 渡されたトークンがダイジェストと一致したらtrueを返す
    def authenticated?(attribute, token)
        digest = send("#{attribute}_digest")  # sendメソッドはメタプログラミングの仕組みを利用した特殊なメソッドなので次を参照「https://railstutorial.jp/chapters/account_activation?version=5.1#sec-generalizing_the_authenticated_method」
        return false if digest.nil?   # BCrypt::Password.new(nil)はエラーになるので、そうなる前にfalse
        BCrypt::Password.new(digest).is_password?(token)
    end

    # ユーザーのログイン情報を破棄する
    def forget
        update_attribute(:remember_digest, nil)
    end

    # アカウントを有効にする
    def activate
        # Userの属性の値を更新(update_attributeはバリデーションを無視)
        # update_attribute(:activated, true)
        # update_attribute(:activated_at, Time.zone.now)

        # 上記だとDBに2回問い合わせすることになるが、以下なら1回の呼び出しにまとめられる
        update_columns(activated: true, activated_at: Time.zone.now)
    end

    # 有効化用のメールを送信する
    def send_activation_email
        UserMailer.account_activation(self).deliver_now
    end

    # パスワード再設定の属性を設定する
    def create_reset_digest
        self.reset_token = User.new_token
        update_columns(reset_digest: User.digest(reset_token), reset_sent_at: Time.zone.now)
    end

    # パスワード再設定のメールを送信する
    def send_password_reset_email
        UserMailer.password_reset(self).deliver_now
    end

    # パスワード再設定の期限が切れている場合はtrueを返す
    def password_reset_expired?
        reset_sent_at < 2.hours.ago  # 2時間以上パスワードが再設定されなかったら期限切れ
    end

    private

        # メールアドレスをすべて小文字にする
        def downcase_email
            # self.email = email.downcase ←以下なら代入しなくて済む
            email.downcase!
        end

        # 有効化トークンとダイジェストを作成および代入する
        def create_activation_digest
            self.activation_token  = User.new_token
            self.activation_digest = User.digest(activation_token)
        end
end
