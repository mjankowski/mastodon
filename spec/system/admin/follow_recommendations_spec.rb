# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Follow Recommendations' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in(user) }

  describe 'Viewing follow recommendations details' do
    it 'shows a list of accounts' do
      visit admin_follow_recommendations_path

      expect(page)
        .to have_text(I18n.t('admin.follow_recommendations.title'))
    end
  end

  describe 'Managing follow recommendation suppression' do
    let!(:account) { Fabricate(:account) }

    it 'suppresses and then restores account recommendations' do
      visit admin_accounts_path
      expect(page)
        .to have_title(I18n.t('admin.accounts.title'))

      click_on account.username
      expect(page)
        .to have_title(account.pretty_acct)
        .and have_link(I18n.t('admin.accounts.follow_recommendations.suppress'))

      expect { click_on I18n.t('admin.accounts.follow_recommendations.suppress') }
        .to change { account.reload.follow_recommendation_suppression }.from(nil).to(be_present)
      expect(page)
        .to have_title(account.pretty_acct)
        .and have_text(I18n.t('admin.accounts.follow_recommendations.suppressed'))
        .and have_link(I18n.t('admin.accounts.follow_recommendations.unsuppress'))

      expect { click_on I18n.t('admin.accounts.follow_recommendations.unsuppress') }
        .to change { account.reload.follow_recommendation_suppression }.from(be_present).to(nil)
      expect(page)
        .to have_title(account.pretty_acct)
        .and have_text(I18n.t('admin.accounts.follow_recommendations.allowed'))
        .and have_link(I18n.t('admin.accounts.follow_recommendations.suppress'))
    end
  end
end
