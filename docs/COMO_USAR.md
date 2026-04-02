# Como usar o WIP para um novo projeto

## O fluxo

```
1. git clone WIP nome-do-projeto
2. Renomear módulo em config/application.rb
3. Configurar banco + bundle install
4. bin/rails db:create db:migrate db:seed
5. Pedir à Claude: "Implemente as regras do sistema X"
```

A Claude já vai saber:
- O layout está pronto (navbar, sidebar, flash, paginação)
- Users, TipoUsuario e Status já existem com CRUD completo
- Devise configurado, CanCanCan configurado
- Padrão de prefixos de módulo (a_, g_, f_, o_...)
- Como adicionar inflexões
- Como criar abilities por perfil
- Auditoria automática (created_by, updated_by, PaperTrail)

## Como adicionar um módulo novo

Exemplo: módulo de Veículos (`g_`)

### 1. Migration

```ruby
# db/migrate/TIMESTAMP_create_g_veiculos.rb
create_table :g_veiculos do |t|
  t.string :placa, null: false
  t.string :modelo
  t.string :created_by
  t.string :updated_by
  t.datetime :deleted_at
  t.timestamps
end
```

### 2. Inflexão

```ruby
# config/initializers/inflections.rb
inflect.irregular 'g_veiculo', 'g_veiculos'
```

### 3. Model

```ruby
class GVeiculo < ApplicationRecord
  include Auditable
  acts_as_paranoid
  has_paper_trail

  validates :placa, presence: true, uniqueness: true
end
```

### 4. Controller

```ruby
class GVeiculosController < ApplicationController
  load_and_authorize_resource

  def index
    @q = GVeiculo.ransack(params[:q])
    @pagy, @g_veiculos = pagy(@q.result)
  end
  # ...
end
```

### 5. Rotas

```ruby
# config/routes.rb
resources :g_veiculos
```

### 6. Ability

```ruby
# app/models/abilities/gestor_ability.rb
main_ability.can :manage, GVeiculo
```

### 7. Sidebar

```erb
<%# app/views/shared/sidebar/_sidebar.html.erb %>
<li class="nav-item">
  <%= link_to g_veiculos_path, class: "nav-link #{sidebar_active_class('g_veiculos')}" do %>
    <i class="ph-car"></i>
    <span>Veículos</span>
  <% end %>
</li>
```

### 8. Views

Crie `app/views/g_veiculos/{index,show,new,edit,_form}.html.erb` seguindo o padrão das views de `users/`.

---

## Helpers disponíveis

| Helper                        | Uso                                    |
|-------------------------------|----------------------------------------|
| `formatar_cpf(cpf)`           | `000.000.000-00`                       |
| `formatar_cnpj(cnpj)`         | `00.000.000/0001-00`                   |
| `formatar_cep(cep)`           | `00000-000`                            |
| `formatar_telefone(tel)`      | `(00) 00000-0000`                      |
| `formatar_data(data)`         | `01/01/2026`                           |
| `formatar_data_hora(dt)`      | `01/01/2026 às 10:30`                  |
| `formatar_moeda(valor)`       | `R$ 1.234,56`                          |
| `formatar_valor_input(valor)` | `1.234,56` (para inputs)               |
| `btn_submit(f)`               | Botão inteligente: Incluir / Atualizar |
| `opcoes_meses`                | Array para selects de mês              |
| `opcoes_anos(inicio:, fim:)`  | Array para selects de ano              |
| `sidebar_active_class(ctrl)`  | Classe `active` para link do menu      |
| `sidebar_section_active?(..)` | Classe `show` para seção colapsável    |
