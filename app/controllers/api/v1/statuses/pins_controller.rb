# frozen_string_literal: true

class Api::V1::Statuses::PinsController < Api::V1::Statuses::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:accounts' }
  before_action :require_user!

  def create
    StatusPin.create!(account: current_account, status: @status)
    distribute_add_activity!
    render json: REST::StatusSerializer.one(@status, current_user: current_user)
  end

  def destroy
    pin = StatusPin.find_by(account: current_account, status: @status)

    if pin
      pin.destroy!
      distribute_remove_activity!
    end

    render json: REST::StatusSerializer.one(@status, current_user: current_user)
  end

  private

  def distribute_add_activity!
    json = ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: ActivityPub::AddSerializer,
      adapter: ActivityPub::Adapter
    ).as_json

    ActivityPub::RawDistributionWorker.perform_async(Oj.dump(json), current_account.id)
  end

  def distribute_remove_activity!
    json = ActiveModelSerializers::SerializableResource.new(
      @status,
      serializer: ActivityPub::RemoveSerializer,
      adapter: ActivityPub::Adapter
    ).as_json

    ActivityPub::RawDistributionWorker.perform_async(Oj.dump(json), current_account.id)
  end
end
