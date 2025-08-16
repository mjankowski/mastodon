# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Instances Delivery Errors' do
  let(:user) { Fabricate(:admin_user) }

  before { sign_in(user) }

  describe 'DELETE #destroy' do
    let(:tracker) { instance_double(DeliveryFailureTracker, clear_failures!: true) }

    before { allow(DeliveryFailureTracker).to receive(:new).and_return(tracker) }

    context 'with a valid domain' do
      before { Instance.refresh }

      let!(:account_popular_main) { Fabricate(:account, domain: 'popular') }

      it 'clears instance delivery errors' do
        delete admin_instance_delivery_errors_path(account_popular_main.domain)

        expect(response)
          .to redirect_to(admin_instance_path(account_popular_main.domain))
        expect(tracker)
          .to have_received(:clear_failures!)
      end
    end

    context 'without any saved domains' do
      it 'clears instance delivery errors' do
        delete admin_instance_delivery_errors_path('domain.example')

        expect(response)
          .to redirect_to(admin_instance_path('domain.example'))
        expect(tracker)
          .to have_received(:clear_failures!)
      end
    end
  end
end
