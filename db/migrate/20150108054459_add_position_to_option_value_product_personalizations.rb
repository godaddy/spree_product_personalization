class AddPositionToOptionValueProductPersonalizations < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_option_value_product_personalizations, :position, :integer, :default => 1
  end
end
