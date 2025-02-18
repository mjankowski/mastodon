# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Terms of Service Histories' do
  before { sign_in(admin_user) }

  describe 'Viewing TOS histories' do
    before { Fabricate :terms_of_service, changelog: 'The changelog notes from v1 are here' }

    it 'shows previous terms versions' do
      visit admin_terms_of_service_history_path

      expect(page)
        .to have_content(I18n.t('admin.terms_of_service.history'))
        .and have_content(/changelog notes from v1/)
    end
  end
end
