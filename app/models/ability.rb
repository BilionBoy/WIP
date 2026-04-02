# frozen_string_literal: true

# Router de abilities — delega para a classe correta conforme o tipo do usuário.
# Adicione novos tipos aqui e crie o arquivo correspondente em app/models/abilities/.
class Ability
  include CanCan::Ability

  def initialize(user)
    return unless user.present?

    if user.admin?
      Abilities::AdminAbility.new(self, user)
    elsif user.gestor?
      Abilities::GestorAbility.new(self, user)
    else
      Abilities::OperadorAbility.new(self, user)
    end
  end
end
