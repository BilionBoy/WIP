module Abilities
  class AdminAbility
    include CanCan::Ability

    def initialize(main_ability, user)
      # Admin pode fazer tudo
      main_ability.can :manage, :all
    end
  end
end
