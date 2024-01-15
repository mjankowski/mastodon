# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers/session_mailer

class SessionMailerPreview < ActionMailer::Preview
  # Preview this email at http://localhost:3000/rails/mailers/session_mailer/welcome
  def welcome
    SessionMailer
      .with(user: User.first)
      .welcome
  end

  # Preview this email at http://localhost:3000/rails/mailers/session_mailer/suspicious_sign_in
  def suspicious_sign_in
    SessionMailer
      .with(user: User.first)
      .suspicious_sign_in(
        '127.0.0.1',
        'Mozilla/5.0 (X11; Ubuntu; Linux x86_64; rv:75.0) Gecko/20100101 Firefox/75.0',
        Time.now.utc
      )
  end
end
