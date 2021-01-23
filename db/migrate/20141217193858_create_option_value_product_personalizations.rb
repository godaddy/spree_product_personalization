class CreateOptionValueProductPersonalizations < ActiveRecord::Migration[4.2]
  def change
    create_table :spree_option_value_product_personalizations do |t|
      t.integer :product_personalization_id
      t.integer :option_value_id
    end

    add_index :spree_option_value_product_personalizations, [:product_personalization_id, :option_value_id], name: 'index_spree_ov_pp_on_pp_id_and_ov_id'
    add_index :spree_option_value_product_personalizations, :product_personalization_id, name: 'index_spree_ov_pp_on_pp_id'
  end
end
