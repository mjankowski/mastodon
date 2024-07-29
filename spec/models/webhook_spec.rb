# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Webhook do
  let(:webhook) { Fabricate(:webhook) }

  describe 'Validations' do
    it { is_expected.to validate_presence_of(:events) }

    it 'requires valid value for events' do
      expect(subject)
        .to_not allow_values(
          [],
          ['account.invalid']
        )
        .for(:events)
    end
  end

  describe 'Normalizations' do
    it 'cleans up events values' do
      expect(subject)
        .to normalize(:events)
        .from(['account.approved', 'account.created     ', ''])
        .to(%w(account.approved account.created))
    end
  end

  describe '#rotate_secret!' do
    it 'changes the secret' do
      expect { webhook.rotate_secret! }
        .to change(webhook, :secret)
      expect(webhook.secret)
        .to_not be_blank
    end
  end

  describe '#enable!' do
    let(:webhook) { Fabricate(:webhook, enabled: false) }

    it 'enables the webhook' do
      expect { webhook.enable! }
        .to change(webhook, :enabled?).to(true)
    end
  end

  describe '#disable!' do
    let(:webhook) { Fabricate(:webhook, enabled: true) }

    it 'disables the webhook' do
      expect { webhook.disable! }
        .to change(webhook, :enabled?).to(false)
    end
  end
end
