# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Trends Approvals' do
  let(:current_user) { Fabricate(:admin_user) }

  before { sign_in current_user }

  describe 'Managing account trends approval' do
    let!(:account) { Fabricate(:account, trendable: false) }

    it 'allows and then disallows an account from appearing in trends' do
      visit admin_accounts_path
      expect(page)
        .to have_title(I18n.t('admin.accounts.title'))

      click_on account.username
      expect(page)
        .to have_title(account.pretty_acct)
        .and have_link(I18n.t('admin.accounts.trends.allow'))

      expect { click_on I18n.t('admin.accounts.trends.allow') }
        .to change { account.reload.trendable? }.from(false).to(true)
      expect(page)
        .to have_title(account.pretty_acct)
        .and have_text(I18n.t('admin.accounts.trends.allowed'))
        .and have_link(I18n.t('admin.accounts.trends.disallow'))

      expect { click_on I18n.t('admin.accounts.trends.disallow') }
        .to change { account.reload.trendable? }.from(true).to(false)
      expect(page)
        .to have_title(account.pretty_acct)
        .and have_text(I18n.t('admin.accounts.trends.disallowed'))
        .and have_link(I18n.t('admin.accounts.trends.allow'))
    end
  end
end
