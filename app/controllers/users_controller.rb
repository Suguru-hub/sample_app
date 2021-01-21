class UsersController < ApplicationController
  def new
  end
  
  def show
    # findメソッドは主キーに対応するレコードを取り出す
    # usersの主キーはidだから、以下のコードはidがparams[:id]と一致するオブジェクトを取得する
    @user = User.find(params[:id])
    # debuggerについて：https://railstutorial.jp/chapters/sign_up?version=5.1#code-debugger
    # 今後実行中によくわからない挙動があったら、下のようにdebuggerを差し込んで調べてみよう
    # デバッグ用メソッドなので通常は削除・コメントアウトしておくべき
    # debugger
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save

    else
      render 'new'
    end
  end

  private

    def user_params
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
