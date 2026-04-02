class CreateAStatus < ActiveRecord::Migration[7.2]
  def change
    create_table :a_status do |t|
      t.string :descricao, null: false

      t.string   :created_by
      t.string   :updated_by
      t.datetime :deleted_at

      t.timestamps
    end

    add_index :a_status, :descricao, unique: true
  end
end
