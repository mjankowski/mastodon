# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Admin Instances Delivery Pauses' do
  let(:user) { Fabricate(:admin_user) }
  let!(:account_popular_main) { Fabricate(:account, domain: 'popular') }

  before do
    Instance.refresh
    sign_in(user)
  end

  describe 'DELETE #destroy' do
    let(:tracker) { instance_double(DeliveryFailureTracker, track_success!: true) }

    before { allow(DeliveryFailureTracker).to receive(:new).and_return(tracker) }

    context 'with an unavailable instance' do
      before { Fabricate(:unavailable_domain, domain: account_popular_main.domain) }

      it 'tracks success on the instance to store deliveries' do
        delete admin_instance_delivery_pause_path(account_popular_main.domain)

        expect(response)
          .to redirect_to(admin_instance_path(account_popular_main.domain))
        expect(tracker)
          .to have_received(:track_success!)
      end
    end

    context 'with an available instance' do
      it 'does not track success on the instance' do
        delete admin_instance_delivery_pause_path(account_popular_main.domain)

        expect(response)
          .to redirect_to(admin_instance_path(account_popular_main.domain))
        expect(tracker)
          .to_not have_received(:track_success!)
      end
    end
  end

  describe 'POST #create' do
    subject { post admin_instance_delivery_pause_path(account_popular_main.domain) }

    it 'makes the domain as unavailable to pause delivery and logs action' do
      expect { subject }
        .to change(UnavailableDomain, :count).by(1)
        .and change(Admin::ActionLog, :count).by(1)

      expect(response)
        .to redirect_to(admin_instance_path(account_popular_main.domain))
    end
  end
end
