class CreateLineItems < ActiveRecord::Migration
  def change
    create_table :line_items do |t|
      t.references :cart, index:true
      t.references :item, index: true
      t.integer :quantity, default: 1

      t.timestamps null:false
    end

  end
end
