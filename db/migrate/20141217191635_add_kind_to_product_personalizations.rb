class AddKindToProductPersonalizations < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_product_personalizations, :kind, :string, default: "text"
  end
end
