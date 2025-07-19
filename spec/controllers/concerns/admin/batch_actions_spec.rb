# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Admin::BatchActions do
  describe '#action_from_button' do
    subject { get :show }

    describe 'when controller does not allow batch operations' do
      controller(ApplicationController) do
        include Admin::BatchActions # rubocop:disable RSpec/DescribedClass

        def show
          render plain: "Action: #{action_from_button}"
        end
      end

      before { routes.draw { get 'show' => 'anonymous#show' } }

      context 'when params are not present' do
        it 'does not set an action' do
          get :show

          expect(response.body)
            .to eq 'Action: '
        end
      end

      context 'when params is an empty hash' do
        it 'does not set an action' do
          get :show, params: {}

          expect(response.body)
            .to eq 'Action: '
        end
      end

      context 'when params are present' do
        it 'does not set an action' do
          get :show, params: { save: 1, special: 2 }

          expect(response.body)
            .to eq 'Action: '
        end
      end
    end

    describe 'when controller allows batch operations' do
      controller(ApplicationController) do
        include Admin::BatchActions # rubocop:disable RSpec/DescribedClass

        allow_batch_operation actions: [:save, :unsave, :presave, :postsave]

        def show
          render plain: "Action: #{action_from_button}"
        end
      end

      before { routes.draw { get 'show' => 'anonymous#show' } }

      context 'when params are not present' do
        it 'does not set an action' do
          get :show

          expect(response.body)
            .to eq 'Action: '
        end
      end

      context 'when params is an empty hash' do
        it 'does not set an action' do
          get :show, params: {}

          expect(response.body)
            .to eq 'Action: '
        end
      end

      context 'when action is in params' do
        it 'sets action from params' do
          get :show, params: { save: 1, special: 2 }

          expect(response.body)
            .to eq 'Action: save'
        end
      end

      context 'when multiple actions are in params' do
        it 'sets action to first matching param' do
          get :show, params: { alpha: 1, unsave: '1', presave: 3 }

          expect(response.body)
            .to eq 'Action: unsave'
        end
      end

      context 'when params do not include actions' do
        it 'does not set an action' do
          get :show, params: { alpha: 1, beta: 2, user: { name: 'name', title: 'Sir' }, final: 'true' }

          expect(response.body)
            .to eq 'Action: '
        end
      end
    end
  end
end
