class AddDescriptionToSpreeProductPersonalizations < ActiveRecord::Migration[4.2]
  def change
    add_column :spree_product_personalizations, :description, :string, after: :name
  end
end
