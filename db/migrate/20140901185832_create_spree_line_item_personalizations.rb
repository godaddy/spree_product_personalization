class CreateSpreeLineItemPersonalizations < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_line_item_personalizations do |t|
      t.integer  :line_item_id
      t.string   :name
      t.decimal  :price,              :precision => 8, :scale => 2
      t.string   :currency
      t.text     :value
      t.timestamps
    end
  end
end
