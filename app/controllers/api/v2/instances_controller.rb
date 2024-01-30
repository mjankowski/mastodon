# frozen_string_literal: true

class Api::V2::InstancesController < Api::V1::InstancesController
  def show
    cache_even_if_authenticated!
    # TODO, eh?!
    render_with_cache json: REST::InstanceSerializer.one(InstancePresenter.new), root: 'instance'
  end
end
