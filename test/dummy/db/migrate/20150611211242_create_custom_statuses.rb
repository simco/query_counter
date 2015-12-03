class CreateCustomStatuses < ActiveRecord::Migration
  def change
    create_table :custom_statuses do |t|
      t.string :name_i18n
      t.boolean :is_system

      t.timestamps null: false
    end
  end
end
