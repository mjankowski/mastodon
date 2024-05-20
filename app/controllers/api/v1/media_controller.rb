# frozen_string_literal: true

class Api::V1::MediaController < Api::BaseController
  before_action -> { doorkeeper_authorize! :write, :'write:media' }
  before_action :require_user!
  before_action :set_media_attachment, except: [:create]
  before_action :check_processing, except: [:create]

  PERMITTED_PARAMS = %i(
    description
    file
    focus
    thumbnail
  ).freeze

  PERMITTED_UPDATE_PARAMS = PERMITTED_PARAMS.without(:file).freeze

  def show
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer, status: status_code_for_media_attachment
  end

  def create
    @media_attachment = current_account.media_attachments.create!(media_attachment_params)
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer
  rescue Paperclip::Errors::NotIdentifiedByImageMagickError
    render json: file_type_error, status: 422
  rescue Paperclip::Error => e
    Rails.logger.error "#{e.class}: #{e.message}"
    render json: processing_error, status: 500
  end

  def update
    @media_attachment.update!(updateable_media_attachment_params)
    render json: @media_attachment, serializer: REST::MediaAttachmentSerializer, status: status_code_for_media_attachment
  end

  private

  def status_code_for_media_attachment
    @media_attachment.not_processed? ? 206 : 200
  end

  def set_media_attachment
    @media_attachment = current_account.media_attachments.where(status_id: nil).find(params[:id])
  end

  def check_processing
    render json: processing_error, status: 422 if @media_attachment.processing_failed?
  end

  def media_attachment_params
    params
      .slice(*PERMITTED_PARAMS)
      .permit(*PERMITTED_PARAMS)
  end

  def updateable_media_attachment_params
    params
      .slice(*PERMITTED_UPDATE_PARAMS)
      .permit(*PERMITTED_UPDATE_PARAMS)
  end

  def file_type_error
    { error: 'File type of uploaded media could not be verified' }
  end

  def processing_error
    { error: 'Error processing thumbnail for uploaded media' }
  end
end
