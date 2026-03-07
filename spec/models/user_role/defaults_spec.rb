# frozen_string_literal: true

require 'rails_helper'

RSpec.describe UserRole::Defaults do
  describe 'Callbacks' do
    describe 'Setting position' do
      context 'when everyone' do
        subject { Fabricate.build :user_role, id: UserRole::EVERYONE_ROLE_ID }

        it 'sets the position to nobody position' do
          expect { subject.valid? }
            .to change(subject, :position).to(UserRole::NOBODY_POSITION)
        end
      end

      context 'when not everyone' do
        subject { Fabricate.build :user_role }

        it 'does not change the position' do
          expect { subject.valid? }
            .to_not change(subject, :position)
        end
      end
    end
  end

  describe '.nobody' do
    subject { UserRole.nobody }

    it 'returns correct role with permissions and position' do
      expect(subject)
        .to be_a(described_class)
        .and be_nobody
        .and have_attributes(
          permissions: UserRole::Flags::NONE,
          position: UserRole::NOBODY_POSITION
        )
    end
  end

  describe '#nobody?' do
    subject { Fabricate.build :user_role }

    context 'when id is nil' do
      before { subject.id = nil }

      it { is_expected.to be_nobody }
    end

    context 'when id is present' do
      before { subject.id = 123 }

      it { is_expected.to_not be_nobody }
    end
  end

  describe '.everyone' do
    subject { UserRole.everyone }

    it 'returns correct role with permissions and position' do
      expect(subject)
        .to be_a(described_class)
        .and be_everyone
        .and have_attributes(
          permissions: UserRole::FLAGS[:invite_users],
          position: UserRole::NOBODY_POSITION
        )
    end
  end

  describe '#everyone?' do
    subject { Fabricate.build :user_role }

    context 'when id matches everyone id' do
      before { subject.id = UserRole::EVERYONE_ROLE_ID }

      it { is_expected.to be_everyone }
    end

    context 'when id does not match everyone id' do
      before { subject.id = 123 }

      it { is_expected.to_not be_everyone }
    end
  end
end
