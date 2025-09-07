class UserMailer < ApplicationMailer
  default from: "tomsterauds@gmail.com"

  def confirmation_email(user)
    @user = user
    @url  = confirm_url(token: @user.confirmation_token)
    mail(to: @user.email_address, subject: "Confirm your account")
  end
end
