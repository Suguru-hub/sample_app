module SessionsHelper

    # 渡されたユーザーでログインする
    def log_in(user)
        session[:user_id] = user.id
    end

    # ユーザーのセッションを永続的にする
    def remember(user)
        user.remember
        # 以下は、次のコードと等価 cookies[:remember_token] = { value: user.id, expires: 20.years.from_now.utc }
        cookies.permanent.signed[:user_id] = user.id
        cookies.permanent[:remember_token] = user.remember_token
    end

    # 永続的セッションを破棄する
    def forget(user)
        user.forget
        cookies.delete(:user_id)
        cookies.delete(:remember_token)
    end

    # 現在のユーザーをログアウトする
    def log_out
        forget(current_user)
        session.delete(:user_id)  # user_idキーの値をnilにする
        # インスタンス変数@current_userをnilにする必要があるのは、
        # @current_userがdestroyアクションより前に作成され (これは該当しません)、
        # かつ、リダイレクトを直接発行しなかった場合だけです(これは該当します)。
        # 現実にこのような条件が発生する可能性はかなり低く、このアプリケーションでも
        # このような条件を作り出さないように開発しているので、本来はnilに設定する必要は
        # ありませんが、ここではセキュリティ上の死角を万が一にでも作り出さないためにあえてnilに設定しています。
        @current_user = nil
    end

    # 記憶トークンcookieに対応するユーザーを返す
    # session[:user_id]が存在すれば一時セッションからユーザーを取り出し、
    # それ以外の場合はcookies[:user_id]からユーザーを取り出して、対応永続セッションにログイン
    def current_user
        # 「ユーザーIDがユーザーIDのセッションと等しければ...」ではなく、
        # 「(ユーザーIDにユーザーIDのセッションを代入した結果) ユーザーIDのセッションが存在すれば」
        if user_id = session[:user_id]
            # "a ||= b" は、"a = a || b"と等価
            # 上の二つの式が等価であること自体はわかると思う
            # 論理演算の仕組みは次がわかりやすい。https://rubychan.net/logical-operator/
            @current_user ||= User.find_by(id: user_id)
        elsif user_id = cookies.signed[:user_id]
            user = User.find_by(id: user_id)
            if user && user.authenticated?(cookies[:remember_token])
                log_in user
                @current_user = user
            end
        end
    end

    # 渡されたユーザーがログイン済みユーザーであればtrueを返す
    def current_user?(user)
        user == current_user
    end

    # ユーザーがログインしていればtrue,その他ならfalse
    def logged_in?
        !current_user.nil?
    end
end
