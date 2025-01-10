# frozen_string_literal: true

RSpec.shared_examples 'User::Activity' do
  describe 'Scopes' do
    describe '.not_signed_in_recently' do
      let!(:no_recent_sign_in_user) { Fabricate(:user, current_sign_in_at: exceed_duration_window_days.ago) }

      before { Fabricate(:user, current_sign_in_at: within_duration_window_days.ago) }

      it 'returns a relation of users who have not signed in during the recent period' do
        expect(User.not_signed_in_recently)
          .to contain_exactly(no_recent_sign_in_user)
      end
    end

    describe '.signed_in_recently' do
      let!(:recent_sign_in_user) { Fabricate(:user, current_sign_in_at: within_duration_window_days.ago) }

      before { Fabricate(:user, current_sign_in_at: exceed_duration_window_days.ago) }

      it 'returns a relation of users who have signed in during the recent period' do
        expect(User.signed_in_recently)
          .to contain_exactly(recent_sign_in_user)
      end
    end

    private

    def exceed_duration_window_days
      described_class::ACTIVE_DURATION + 2.days
    end

    def within_duration_window_days
      described_class::ACTIVE_DURATION - 2.days
    end
  end
end
