# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin::Statuses' do
  before { sign_in(admin_user) }

  describe 'Performing batch updates' do
    before do
      _status = Fabricate(:status, account: admin_user.account)
      visit admin_account_statuses_path(account_id: admin_user.account_id)
    end

    context 'without selecting any records' do
      it 'displays a notice about selection' do
        click_on button_for_report

        expect(page).to have_content(selection_error_text)
      end
    end

    def button_for_report
      I18n.t('admin.statuses.batch.report')
    end

    def selection_error_text
      I18n.t('admin.statuses.no_status_selected')
    end
  end
end
