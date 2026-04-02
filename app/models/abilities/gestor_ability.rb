module Abilities
  class GestorAbility
    include CanCan::Ability

    def initialize(main_ability, user)
      Abilities::BaseAbility.new(main_ability, user)

      # Defina aqui o que gestores podem fazer.
      # Exemplo:
      # main_ability.can :read,    User
      # main_ability.can :manage,  [SeuModelo, OutroModelo]
    end
  end
end
