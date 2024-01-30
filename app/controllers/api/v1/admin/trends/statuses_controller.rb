# frozen_string_literal: true

class Api::V1::Admin::Trends::StatusesController < Api::V1::Trends::StatusesController
  include Authorization

  before_action -> { authorize_if_got_token! :'admin:read' }, only: :index
  before_action -> { authorize_if_got_token! :'admin:write' }, except: :index

  after_action :verify_authorized, except: :index

  def index
    if current_user&.can?(:manage_taxonomies)
      render json: REST::Admin::Trends::StatusSerializer.many(@statuses)
    else
      super
    end
  end

  def approve
    authorize [:admin, :status], :review?

    status = Status.find(params[:id])
    status.update(trendable: true)
    render json: REST::Admin::Trends::StatusSerializer.one(status)
  end

  def reject
    authorize [:admin, :status], :review?

    status = Status.find(params[:id])
    status.update(trendable: false)
    render json: REST::Admin::Trends::StatusSerializer.one(status)
  end

  private

  def enabled?
    super || current_user&.can?(:manage_taxonomies)
  end

  def statuses_from_trends
    if current_user&.can?(:manage_taxonomies)
      Trends.statuses.query
    else
      super
    end
  end
end
