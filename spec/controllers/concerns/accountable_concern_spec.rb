# frozen_string_literal: true

require 'rails_helper'

RSpec.describe AccountableConcern do
  let(:hoge_class) do
    Class.new do
      include AccountableConcern
    end
  end

  let(:user)   { Fabricate(:account) }
  let(:target) { Fabricate(:account) }
  let(:hoge)   { hoge_class.new }

  describe '#log_action' do
    before { Rails.event.set_context account_id: user.id }

    it 'creates Admin::ActionLog' do
      expect { hoge.log_action(:create, target) }
        .to change(Admin::ActionLog, :count).by(1)
    end
  end
end
