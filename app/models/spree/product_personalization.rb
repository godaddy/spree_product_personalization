# frozen_string_literal: true

module Spree
  class ProductPersonalization < ActiveRecord::Base
    include Spree::Core::CalculatedAdjustments
    TEXT_LIMIT = 2000
    LABEL_LIMIT = 100
    DESCRIPTION_LIMIT = 200

    belongs_to :product
    has_many :option_value_product_personalizations, -> { order(:position) }, class_name: 'Spree::OptionValueProductPersonalization', dependent: :destroy, inverse_of: :product_personalization
    has_many :option_values, class_name: 'Spree::OptionValueProductPersonalization', through: :option_value_product_personalizations
    accepts_nested_attributes_for :option_value_product_personalizations, allow_destroy: true

    validates :name, length: { minimum: 1, maximum: LABEL_LIMIT }
    validates :name, uniqueness: { scope: :product_id }
    validates :description, length: { maximum: DESCRIPTION_LIMIT }
    validates :limit, numericality: { only_integer: true, greater_than: 0, less_than_or_equal_to: TEXT_LIMIT }
    validates :kind, inclusion: { in: %w(text list), message: "%{value} is not a valid type of personalization" }
    validate :check_price
    validate :check_kind

    before_validation { self.name = self.name.strip if self.name }

    def self.permitted_attributes
      [:id, :name, :description, :kind, :required, :limit, :_destroy, calculator_attributes: [:id, :type, :preferred_amount]]
    end

    def text?
      kind == 'text'
    end

    def list?
      kind == 'list'
    end

    def increase_price(index = 0)
      price = 0
      if text?
        price = self.calculator.preferred_amount
      elsif list?
        ovp = self.option_value_product_personalizations[index]
        price = ovp.calculator.preferred_amount if ovp
      end
      price
    end

    private

    def check_price
      if self.calculator.preferred_amount < 0
        errors.add(:base, Spree.t('errors.increasing_price_can_not_be_negative'))
      end
    end

    def check_kind
      if text? && option_value_product_personalizations.present?
        errors.add(:base, Spree.t('errors.personalization_text_cannot_have_options'))
      end

      if list? && option_value_product_personalizations.empty?
        errors.add(:base, Spree.t('errors.personalization_options_should_have_options'))
      end
    end
  end
end
