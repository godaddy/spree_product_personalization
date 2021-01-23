class AddLimitToLineItemPersonalization < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_line_item_personalizations, :limit, :integer, :default => 255
  end
end
