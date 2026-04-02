# frozen_string_literal: true

class DeviseCreateUsers < ActiveRecord::Migration[7.2]
  def change
    create_table :users do |t|
      ## Campos do projeto
      t.string :nome,     null: false
      t.string :cpf,      null: false
      t.string :telefone

      ## Relacionamentos de administração
      t.bigint :a_tipo_usuario_id, null: false
      t.bigint :a_status_id,       null: false

      ## Auditoria
      t.string :created_by
      t.string :updated_by

      ## Devise — Database Authenticatable
      t.string :email,              null: false, default: ''
      t.string :encrypted_password, null: false, default: ''

      ## Devise — Recoverable
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Devise — Rememberable
      t.datetime :remember_created_at

      ## Paranoia (soft delete)
      t.datetime :deleted_at

      t.timestamps null: false
    end

    add_index :users, :email,                unique: true
    add_index :users, :cpf,                  unique: true
    add_index :users, :reset_password_token, unique: true
    add_index :users, :a_tipo_usuario_id
    add_index :users, :a_status_id
    add_index :users, :deleted_at

    add_foreign_key :users, :a_tipo_usuarios
    add_foreign_key :users, :a_status
  end
end
