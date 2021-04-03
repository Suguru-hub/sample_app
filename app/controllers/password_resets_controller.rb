# updateアクションでは、次の4つのケースを考慮する必要がある。
# 1. パスワード再設定の有効期限が切れていないか
# 2. 無効なパスワードであれば失敗させる
# 3. 新しいパスワードが空文字列になっていないか（ユーザー情報の編集ではOKだった）
# 4. 新しいパスワードが正しければ更新する

class PasswordResetsController < ApplicationController
  before_action :get_user,         only: [:edit, :update]
  before_action :valid_user,       only: [:edit, :update]
  before_action :check_expiration, only: [:edit, :update]  # (1)への対応

  def new
  end

  # パスワード再設定用のアクション。「forgot password」フォームのSubmitボタンを押すと呼び出される
  def create
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    if @user
      @user.create_reset_digest
      @user.send_password_reset_email
      flash[:info] = "Email sent with password reset instructions"
      redirect_to root_url
    else
      flash.now[:danger] = "Email address not found"
      render 'new'
    end
  end

  def edit
  end

  def update
    if params[:user][:password].empty?   # (3)への対応
      # @userオブジェクトにエラーメッセージを追加。
      # パスワードが空だった時に空の文字列に対するデフォルトメッセージを表示してくれるようになる。
      @user.errors.add(:password, :blank)
      render 'edit'
    elsif @user.update_attributes(user_params)  # (4)への対応
      log_in @user
      @user.update_attribute(:reset_digest, nil)  # パスワード再設定が成功したらダイジェストをnilにする(リスト12.22)
      flash[:success] = "Password has been reset."
      redirect_to @user
    else
      render 'edit'                        # (2)への対応
    end
  end

  private

    # Strong Parameters セキュリティが強い(意図しない・安全でないデータの登録・更新を防いでくれる)
    # https://qiita.com/ozackiee/items/f100fd51f4839b3fdca8
    def user_params
      # 送信されてくるparamsに:userというキーが必須で、
      # :userはハッシュ型の値を持っていて、それには:password,:password_confirmationのキーのみを許可すると下記コードは言っている。
      # 許可していないカラム(キー)が存在した場合、そのデータは取得されず無視される。
      # このコードの戻り値は、許可された属性のみが含まれたparamsのハッシュ.
      params.require(:user).permit(:password, :password_confirmation)
    end

    # beforeフィルタ群

    def get_user
      @user = User.find_by(email: params[:email])
    end

    # 正しいユーザーかどうか確認する
    def valid_user
      unless (@user && @user.activated? && @user.authenticated?(:reset, params[:id]))
        redirect_to root_url
      end
    end

    # トークンが期限切れかどうか確認する
    def check_expiration
      if @user.password_reset_expired?
        flash[:danger] = "Password reset has expired."
        redirect_to new_password_reset_url
      end
    end
end
