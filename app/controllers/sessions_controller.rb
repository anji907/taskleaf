class SessionsController < ApplicationController
  skip_before_action :login_required
  
  def new
  end

  def create
    #ログインフォームから送信されたemailを元にユーザーを検索
    user = User.find_by(email: session_params[:email])

    if user&.authenticate(session_params[:password])
      #ユーザーIDをセッションに保存
      session[:user_id] = user.id
      redirect_to root_url, notice: "ログインしました。"
    else
      render :new
    end
  end

  def destroy
    reset_session
    redirect_to root_url, notice: 'ログアウトしました。'
  end

  private

  def session_params
    params.require(:session).permit(:email, :password)
  end
end
