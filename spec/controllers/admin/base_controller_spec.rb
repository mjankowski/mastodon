# frozen_string_literal: true

require 'rails_helper'

describe Admin::BaseController do
  render_views

  controller do
    def success
      authorize :dashboard, :index?
      render html: 'ok', layout: true
    end
  end

  it 'requires administrator or moderator' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user))
    get :success

    expect(response).to have_http_status(403)
  end

  it 'returns private cache control headers' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Moderator')))
    get :success

    expect(response).to have_http_header('Cache-Control', 'private, no-store')
  end

  it 'renders admin layout as a moderator' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Moderator')))
    get :success
    expect(response.body).to include('admin-wrapper')
  end

  it 'renders admin layout as an admin' do
    routes.draw { get 'success' => 'admin/base#success' }
    sign_in(Fabricate(:user, role: UserRole.find_by(name: 'Admin')))
    get :success
    expect(response.body).to include('admin-wrapper')
  end
end
