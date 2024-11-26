# frozen_string_literal: true

if Rails.env.local?
  namespace :dev do
    desc 'Sample data for local development environment'
    task prime: 'db:setup' do
      domain = ENV['LOCAL_DOMAIN'] || Rails.configuration.x.local_domain
      domain = domain.gsub(/:\d+$/, '')

      # Create an admin account
      admin = Account.where(username: 'admin').first_or_initialize(username: 'admin')
      admin.save(validate: false)

      # Create a user connected to the admin account
      user = User.where(email: "admin@#{domain}").first_or_initialize(email: "admin@#{domain}", password: 'mastodonadmin', password_confirmation: 'mastodonadmin', confirmed_at: Time.now.utc, role: UserRole.find_by(name: 'Owner'), account: admin, agreement: true, approved: true)
      user.save!
      user.approve!
    end
  end
end
