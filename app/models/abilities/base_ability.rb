module Abilities
  class BaseAbility
    # Abilities compartilhadas por todos os perfis.
    # Inclua aqui permissões mínimas que qualquer usuário autenticado possui.
    def initialize(main_ability, user)
      # Exemplo: main_ability.can :read, :dashboard
    end
  end
end
