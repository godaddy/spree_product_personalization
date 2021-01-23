class AddPersonalizationIdToLineItemPersonalization < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_line_item_personalizations, :spree_product_personalization_id, :integer
  end
end
