class CreateStatuses < ActiveRecord::Migration
  def change
    create_table :statuses do |t|
      t.string :name
      t.boolean :is_system

      t.timestamps null: false
    end
  end
end
