module SessionsHelper

    # 渡されたユーザーでログインする
    def log_in(user)
        session[:user_id] = user.id
    end

    # 現在のユーザーをログアウトする
    def log_out
        session.delete(:user_id)  # user_idキーの値をnilにする
        # インスタンス変数@current_userをnilにする必要があるのは、
        # @current_userがdestroyアクションより前に作成され (これは該当しません)、
        # かつ、リダイレクトを直接発行しなかった場合だけです(これは該当します)。
        # 現実にこのような条件が発生する可能性はかなり低く、このアプリケーションでも
        # このような条件を作り出さないように開発しているので、本来はnilに設定する必要は
        # ありませんが、ここではセキュリティ上の死角を万が一にでも作り出さないためにあえてnilに設定しています。
        @current_user = nil
    end

    # 現在ログイン中のユーザーを返す(いる場合)
    def current_user
        if session[:user_id]
            # "a ||= b" は、"a = a || b"と等価
            # 上の二つの式が等価であること自体はわかると思う
            # 論理演算の仕組みは次がわかりやすい。https://rubychan.net/logical-operator/
            @current_user ||= User.find_by(id: session[:user_id])
        end
    end

    # ユーザーがログインしていればtrue,その他ならfalse
    def logged_in?
        !current_user.nil?
    end
end
