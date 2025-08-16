# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::InstancesController do
  render_views

  let(:current_user) { Fabricate(:admin_user) }

  let!(:account_popular_main) { Fabricate(:account, domain: 'popular') }

  before do
    _account_less_popular = Fabricate(:account, domain: 'less.popular')
    _account_popular_other = Fabricate(:account, domain: 'popular')
    Instance.refresh

    sign_in current_user, scope: :user
  end

  describe 'GET #index' do
    around do |example|
      default_per_page = Instance.default_per_page
      Instance.paginates_per 1
      example.run
      Instance.paginates_per default_per_page
    end

    it 'renders instances' do
      get :index, params: { page: 2 }

      expect(instance_directory_links.size).to eq(1)
      expect(instance_directory_links.first.text.strip).to match('less.popular')

      expect(response).to have_http_status(200)
    end

    def instance_directory_links
      response.parsed_body.css('div.directory__tag a')
    end
  end

  describe 'GET #show' do
    before do
      allow(Admin::ActionLogFilter).to receive(:new).and_call_original
    end

    it 'shows an instance page' do
      get :show, params: { id: account_popular_main.domain }

      expect(response).to have_http_status(200)

      expect(response.body)
        .to include(I18n.t('admin.instances.totals_time_period_hint_html'))
        .and include(I18n.t('accounts.nothing_here'))

      expect(Admin::ActionLogFilter).to have_received(:new).with(target_domain: account_popular_main.domain)
    end
  end

  describe 'DELETE #destroy' do
    subject { delete :destroy, params: { id: Instance.first.id } }

    let(:current_user) { Fabricate(:user, role: role) }
    let(:account) { Fabricate(:account) }

    context 'when user is admin' do
      let(:role) { UserRole.find_by(name: 'Admin') }

      it 'succeeds in purging instance' do
        expect(subject).to redirect_to admin_instances_path
      end
    end

    context 'when user is not admin' do
      let(:role) { nil }

      it 'fails to purge instance' do
        expect(subject).to have_http_status 403
      end
    end
  end
end
