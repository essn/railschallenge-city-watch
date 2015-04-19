class CreateEmergencies < ActiveRecord::Migration
  def change
    create_table :emergencies do |t|
      t.timestamps null: false
      t.datetime :resolved_at
      t.string :code
      t.integer :police_severity
      t.integer :medical_severity
      t.integer :fire_severity
    end
  end
end
