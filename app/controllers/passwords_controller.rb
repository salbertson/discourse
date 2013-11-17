class PasswordsController < ApplicationController
  skip_before_filter :check_xhr
  skip_before_filter :redirect_to_login_if_required

  def edit
    expires_now

    @user = EmailToken.confirm(params[:token])
    if @user.blank?
      flash[:error] = I18n.t('password_reset.no_token')
    end
    render layout: 'no_js'
  end

  def update
    raise Discourse::InvalidParameters.new(:password) unless params[:password].present?
    @user = EmailToken.confirm(params[:token])
    @user.password = params[:password]
    if @user.save
      logon_after_password_reset
    else
      render :edit
    end
  end

  private

  def logon_after_password_reset
    message = if Guardian.new(@user).can_access_forum?
                log_on_user(@user)
                'password_reset.success'
              else
                @requires_approval = true
                'password_reset.success_unapproved'
              end

    flash[:success] = I18n.t(message)
   end
end
