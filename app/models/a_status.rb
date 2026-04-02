class AStatus < ApplicationRecord
  include Auditable

  has_many :users

  acts_as_paranoid

  validates :descricao, presence: true, uniqueness: true

  # Status padrão que o sistema espera encontrar (seeds)
  # Exemplos: 'Ativo', 'Inativo', 'Bloqueado'
end
