class AddOptionValueProductPersonalizationIdToLineItemPersonalization < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_line_item_personalizations, :spree_option_value_product_personalization_id, :integer
  end
end
