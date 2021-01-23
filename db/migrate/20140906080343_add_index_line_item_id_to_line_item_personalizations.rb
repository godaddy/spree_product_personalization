class AddIndexLineItemIdToLineItemPersonalizations < ActiveRecord::Migration[4.2]
  def change
    add_index :spree_line_item_personalizations, :line_item_id
  end
end
