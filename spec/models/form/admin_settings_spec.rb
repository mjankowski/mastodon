# frozen_string_literal: true

require 'rails_helper'

describe Form::AdminSettings do
  describe 'validations' do
    describe 'site_contact_username' do
      context 'with no accounts' do
        it 'is not valid' do
          expect(subject)
            .to_not allow_values(
              'Test'
            )
            .for(:site_contact_username)
        end
      end

      context 'with an account' do
        before { Fabricate(:account, username: 'Glorp') }

        it 'is not valid when account doesnt match' do
          expect(subject)
            .to_not allow_values(
              'Test'
            )
            .for(:site_contact_username)
        end

        it 'is valid when account matches' do
          expect(subject)
            .to allow_values(
              'Glorp'
            )
            .for(:site_contact_username)
        end
      end
    end
  end
end
