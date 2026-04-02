class ATipoUsuario < ApplicationRecord
  include Auditable

  has_many :users

  acts_as_paranoid

  validates :descricao, presence: true, uniqueness: true

  # Tipos padrão que o sistema espera encontrar (seeds)
  # Exemplos: 'Admin', 'Gestor', 'Operador'
end
