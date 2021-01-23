# frozen_string_literal: true

module Spree
  class OptionValueProductPersonalization < ApplicationRecord
    include Spree::Core::CalculatedAdjustments

    belongs_to :product_personalization, class_name: 'Spree::ProductPersonalization', inverse_of: :option_value_product_personalizations
    belongs_to :option_value, class_name: 'Spree::OptionValue', inverse_of: :option_value_product_personalizations

    def product_personalization_amount
      product_personalization.increase_price(position - 1)
    end
  end
end
