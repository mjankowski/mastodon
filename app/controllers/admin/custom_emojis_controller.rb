# frozen_string_literal: true

module Admin
  class CustomEmojisController < BaseController
    allow_batch_operation actions: %i(update list unlist enable disable copy delete)

    def index
      authorize :custom_emoji, :index?

      @custom_emojis = filtered_custom_emojis.eager_load(:local_counterpart).page(params[:page])
      @form          = Form::CustomEmojiBatch.new
    end

    def new
      authorize :custom_emoji, :create?

      @custom_emoji = CustomEmoji.new
    end

    def create
      authorize :custom_emoji, :create?

      @custom_emoji = CustomEmoji.new(resource_params)

      if @custom_emoji.save
        log_action :create, @custom_emoji
        redirect_to admin_custom_emojis_path, notice: I18n.t('admin.custom_emojis.created_msg')
      else
        render :new
      end
    end

    def batch
      authorize :custom_emoji, :index?

      @form = Form::CustomEmojiBatch.new(form_custom_emoji_batch_params.merge(current_account: current_account, action: action_from_button))
      @form.save
    rescue ActionController::ParameterMissing
      flash[:alert] = I18n.t('admin.custom_emojis.no_emoji_selected')
    rescue Mastodon::NotPermittedError
      flash[:alert] = I18n.t('admin.custom_emojis.not_permitted')
    ensure
      redirect_to admin_custom_emojis_path(filter_params)
    end

    private

    def resource_params
      params
        .expect(custom_emoji: [:shortcode, :image, :visible_in_picker])
    end

    def filtered_custom_emojis
      CustomEmojiFilter.new(filter_params).results
    end

    def filter_params
      params.slice(:page, *CustomEmojiFilter::KEYS).permit(:page, *CustomEmojiFilter::KEYS)
    end

    def form_custom_emoji_batch_params
      params
        .expect(form_custom_emoji_batch: [:action, :category_id, :category_name, custom_emoji_ids: []])
    end
  end
end
