# frozen_string_literal: true

shared_examples 'forbidden for wrong scope' do |wrong_scope|
  let(:scopes) { wrong_scope }

  it 'returns http forbidden' do
    expect(response).to have_http_status(403)
  end
end

shared_examples 'forbidden for wrong role' do |wrong_role|
  let(:role) { UserRole.find_by(name: wrong_role) }

  it 'returns http forbidden' do
    expect(response).to have_http_status(403)
  end
end
