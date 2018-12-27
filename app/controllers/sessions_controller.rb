class SessionsController < ApplicationController
  layout "alternate"

  def new
  end

  def create
    if auth
      @user = User.find_by(email: auth['info']['email'])
      if @user
        session[:user_id] = @user.id
        redirect_to user_path(@user)

      else
        @user = User.create(name: auth['info']['name'], email: auth['info']['email'], password: SecureRandom.urlsafe_base64, password_confirmation: SecureRandom.urlsafe_base64)
        session[:user_id] = @user.id
        redirect_to user_path(@user)
      end
    else
      @user = User.find_by(email: params[:session][:email].downcase)
      if @user && @user.authenticate(params[:session][:password])
        log_in @user
        params[:session][:remember_me] == '1' ? remember(@user) : forget(@user)
        redirect_back_or @user
      else
        flash.now[:danger] = "Email or password not valid"
        render 'new'
      end
    end
  end

  def destroy
    log_out if logged_in?
    redirect_to root_url
  end

  private

    def auth
      request.env['omniauth.auth']
    end
end
