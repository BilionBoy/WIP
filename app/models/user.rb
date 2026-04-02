# frozen_string_literal: true

class User < ApplicationRecord
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  acts_as_paranoid
  has_paper_trail

  belongs_to :a_tipo_usuario
  belongs_to :a_status

  has_one_attached :foto_perfil

  before_validation :normalize_cpf

  validates :nome,  presence: true
  validates :email, presence: true
  validates :cpf,   presence: true, uniqueness: true
  validate  :email_deve_ser_unico_incluindo_excluidos

  # ─── Helpers de tipo ─────────────────────────────────────────────────────────
  def admin?
    a_tipo_usuario&.descricao&.downcase == 'admin'
  end

  def gestor?
    a_tipo_usuario&.descricao&.downcase == 'gestor'
  end

  def operador?
    a_tipo_usuario&.descricao&.downcase == 'operador'
  end

  # Adicione outros tipos conforme o projeto:
  # def supervisor?
  #   a_tipo_usuario&.descricao&.downcase == 'supervisor'
  # end

  private

  def email_deve_ser_unico_incluindo_excluidos
    return if email.blank?

    existente = User.with_deleted.find_by(email: email)
    return if existente.blank? || existente.id == id

    if existente.deleted_at.present?
      errors.add(:email, 'já pertence a um usuário excluído. Restaure o cadastro para reutilizar este e-mail.')
    else
      errors.add(:email, 'já está em uso')
    end
  end

  def normalize_cpf
    self.cpf = cpf.gsub(/\D/, '') if cpf.present?
  end
end
