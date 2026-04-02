module Abilities
  class OperadorAbility
    include CanCan::Ability

    def initialize(main_ability, user)
      Abilities::BaseAbility.new(main_ability, user)

      # Defina aqui o que operadores podem fazer.
      # Exemplo:
      # main_ability.can :read, SeuModelo
    end
  end
end
