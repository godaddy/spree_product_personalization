# frozen_string_literal: true

module Spree
  class ApplicationRecord < ActiveRecord::Base
    self.abstract_class = true
  end
end
