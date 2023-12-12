# frozen_string_literal: true

require 'rails_helper'

describe 'Accounts Statuses RSS' do
  let(:account) { Fabricate(:account) }

  describe 'unapproved account check' do
    before { account.user.update(approved: false) }

    it 'returns http not found' do
      %w(rss).each do |format|
        get short_account_path(username: account.username, format: format)
        expect(response).to have_http_status(404)
      end
    end
  end

  describe 'permanently suspended account check' do
    before do
      account.suspend!
      account.deletion_request.destroy
    end

    it 'returns http gone' do
      %w(rss).each do |format|
        get short_account_path(username: account.username, format: format)
        expect(response).to have_http_status(410)
      end
    end
  end

  describe 'temporarily suspended account check' do
    before { account.suspend! }

    it 'returns appropriate http response code' do
      { rss: 403 }.each do |format, code|
        get short_account_path(username: account.username, format: format)

        expect(response).to have_http_status(code)
      end
    end
  end

  describe 'GET /@username RSS paths' do
    context 'with existing statuses' do
      let!(:status) { Fabricate(:status, account: account) }
      let!(:status_reply) { Fabricate(:status, account: account, thread: Fabricate(:status)) }
      let!(:status_self_reply) { Fabricate(:status, account: account, thread: status) }
      let!(:status_media) { Fabricate(:status, account: account) }
      let!(:status_pinned) { Fabricate(:status, account: account) }
      let!(:status_private) { Fabricate(:status, account: account, visibility: :private) }
      let!(:status_direct) { Fabricate(:status, account: account, visibility: :direct) }
      let!(:status_reblog) { Fabricate(:status, account: account, reblog: Fabricate(:status)) }

      before do
        status_media.media_attachments << Fabricate(:media_attachment, account: account, type: :image)
        account.pinned_statuses << status_pinned
        account.pinned_statuses << status_private
      end

      context 'with RSS' do
        let(:format) { 'rss' }

        describe 'GET /@username.rss' do
          before do
            get short_account_path(username: account.username, format: format)
          end

          it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'

          it 'responds with correct statuses', :aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response.body).to include_status_tag(status_media)
            expect(response.body).to include_status_tag(status_self_reply)
            expect(response.body).to include_status_tag(status)
            expect(response.body).to_not include_status_tag(status_direct)
            expect(response.body).to_not include_status_tag(status_private)
            expect(response.body).to_not include_status_tag(status_reblog.reblog)
            expect(response.body).to_not include_status_tag(status_reply)
          end
        end

        describe 'GET /@username/with_replies.rss' do
          before do
            get short_account_with_replies_path(username: account.username, format: format)
          end

          it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'

          it 'responds with correct statuses with replies', :aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response.body).to include_status_tag(status_media)
            expect(response.body).to include_status_tag(status_reply)
            expect(response.body).to include_status_tag(status_self_reply)
            expect(response.body).to include_status_tag(status)
            expect(response.body).to_not include_status_tag(status_direct)
            expect(response.body).to_not include_status_tag(status_private)
            expect(response.body).to_not include_status_tag(status_reblog.reblog)
          end
        end

        describe 'GET /@username/media.rss' do
          before do
            get short_account_media_path(username: account.username, format: format)
          end

          it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'

          it 'responds with correct statuses with media', :aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response.body).to include_status_tag(status_media)
            expect(response.body).to_not include_status_tag(status_direct)
            expect(response.body).to_not include_status_tag(status_private)
            expect(response.body).to_not include_status_tag(status_reblog.reblog)
            expect(response.body).to_not include_status_tag(status_reply)
            expect(response.body).to_not include_status_tag(status_self_reply)
            expect(response.body).to_not include_status_tag(status)
          end
        end

        describe 'GET /@username/tags/tag.rss' do
          let(:tag) { Fabricate(:tag) }

          let!(:status_tag) { Fabricate(:status, account: account) }

          before do
            status_tag.tags << tag
            get short_account_tag_path(username: account.username, tag: tag, format: format)
          end

          it_behaves_like 'cacheable response', expects_vary: 'Accept, Accept-Language, Cookie'

          it 'responds with correct statuses with a tag', :aggregate_failures do
            expect(response).to have_http_status(200)
            expect(response.body).to include_status_tag(status_tag)
            expect(response.body).to_not include_status_tag(status_direct)
            expect(response.body).to_not include_status_tag(status_media)
            expect(response.body).to_not include_status_tag(status_private)
            expect(response.body).to_not include_status_tag(status_reblog.reblog)
            expect(response.body).to_not include_status_tag(status_reply)
            expect(response.body).to_not include_status_tag(status_self_reply)
            expect(response.body).to_not include_status_tag(status)
          end
        end
      end
    end
  end

  def include_status_tag(status)
    include ActivityPub::TagManager.instance.url_for(status)
  end
end
