class CreateSpreeProductPersonalizations < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_product_personalizations do |t|
      t.integer  :product_id
      t.string   :name
      t.boolean  :required,           :default => false
      t.integer  :limit,              :default => 255
      t.timestamps
    end
  end
end
