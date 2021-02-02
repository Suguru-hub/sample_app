module SessionsHelper

    # 渡されたユーザーでログインする
    def log_in(user)
        session[:user_id] = user.id
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
end
