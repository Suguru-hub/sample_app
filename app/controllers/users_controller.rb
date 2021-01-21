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

  # Strong Parameters セキュリティが強い(意図しない・安全でないデータの登録・更新を防いでくれる)
  # https://qiita.com/ozackiee/items/f100fd51f4839b3fdca8
    def user_params
      # 送信されてくるパラメータに:userというキーが必須で、
      # :userはハッシュ型の値を持っていて、それには:name,:email...のキーのみを許可すると下記コードは言っている。
      # 許可していないカラム(キー)が存在した場合、そのデータは取得されず無視される。
      # 例えば以下のコードなら、:userのハッシュに:unkoキーがあったら,permitに指定されていないので
      # 無視される。
      # このコードの戻り値は、許可された属性のみが含まれたparamsのハッシュ.つまり:userハッシュ
      params.require(:user).permit(:name, :email, :password,
                                   :password_confirmation)
    end
end
