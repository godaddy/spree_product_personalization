class AddIndexProductIdToProductPersonalizations < ActiveRecord::Migration[4.2]
  def change
    add_index :spree_product_personalizations, :product_id
  end
end
