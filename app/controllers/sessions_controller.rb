class SessionsController < ApplicationController
  def new
  end

  def create
    user = User.find_by(email: params[:session][:email].downcase)
    if user && user.authenticate(params[:session][:password])
      # ユーザーログイン後にユーザー情報のページにリダイレクトする
    else
      ## flash[:danger] = 'Invalid email/password combination' ##
      # ↑のコードのままでは、リクエストのフラッシュメッセージが一度表示されると
      # 消えずに残ってしまいます。リダイレクトを使ったときとは異なり、表示した
      # テンプレートをrenderメソッドで強制的に再レンダリングしてもリクエストと
      # 見なされないため、リクエストのメッセージが消えません。例えばわざと無効
      # な情報を入力して送信してエラーメッセージを表示してから、Homeページをク
      # リックして移動しても、そこでもフラッシュメッセージが表示されたままにな
      # ってしまう。
      # そこで、flash.nowを使う。
      # flashのメッセージとは異なり、
      # flash.nowのメッセージはその後リクエストが発生したときに消滅します
      # 解説記事：https://qiita.com/taraontara/items/2db82e6a0b528b06b949#%E3%81%97%E3%81%8F%E3%81%BF
      flash.now[:danger] = 'Invalid email/password combination'
      render 'new'
    end
  end

  def destroy
  end
end
