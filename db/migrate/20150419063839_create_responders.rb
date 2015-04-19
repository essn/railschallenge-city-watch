class CreateResponders < ActiveRecord::Migration
  def change
    create_table :responders do |t|
      t.timestamps null: false
      t.string :type
      t.integer :emergency_code
      t.string :name
      t.integer :capacity
      t.boolean :on_duty
    end
  end
end
