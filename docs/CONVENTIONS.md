# Convenções do projeto WIP

## Nomenclatura de models e tabelas

- Use **prefixos de módulo** para agrupar modelos relacionados sem criar pastas:
  ```
  a_tipo_usuario  → tabela: a_tipo_usuarios
  g_municipio     → tabela: g_municipios
  ```
- Adicione toda inflexão irregular em `config/initializers/inflections.rb`
- Nome do model em CamelCase sem underscores:
  ```
  a_tipo_usuario → ATipoUsuario
  g_municipio    → GMunicipio
  ```

## Campos padrão em cada tabela

Todo model deve ter:
```ruby
t.string   :created_by   # CPF ou e-mail de quem criou
t.string   :updated_by   # CPF ou e-mail de quem alterou por último
t.datetime :deleted_at   # Paranoia (soft delete)
t.timestamps             # created_at, updated_at
```

Inclua no model:
```ruby
include Auditable
acts_as_paranoid
has_paper_trail          # apenas quando rastrear histórico de mudanças
```

## Controllers

- Sempre use `load_and_authorize_resource` (CanCanCan)
- Paginação: `@pagy, @registros = pagy(@q.result)`
- Filtros: `@q = Model.ransack(params[:q])` + `search_form_for @q`
- Redirects pós-update: `status: :see_other`

## Views

- **Breadcrumb**: use `render "shared/context_nav"` com um bloco
- **Flash**: renderizado automaticamente pelo layout via `shared/_flash`
- **Paginação**: `render "shared/pagy", pagy: @pagy` dentro de `card-footer`
- **Formulários**: sempre `simple_form_for` com `f.input`
- **Botão submit**: use `btn_submit(f)` do ApplicationHelper

## Sidebar

Para adicionar um item no menu, edite `app/views/shared/sidebar/_sidebar.html.erb`:

```erb
<li class="nav-item">
  <%= link_to modelo_path, class: "nav-link #{sidebar_active_class('modelo')}" do %>
    <i class="ph-icone"></i>
    <span>Nome do módulo</span>
  <% end %>
</li>
```

## Abilities

Após criar um novo model, defina quem pode fazer o quê:

```ruby
# app/models/abilities/gestor_ability.rb
main_ability.can :manage, SeuModelo
main_ability.can :read,   OutroModelo
```

## Inflexões

Para cada novo model com nome irregular:

```ruby
# config/initializers/inflections.rb
inflect.irregular 'x_nome_singular', 'x_nomes_plural'
```

## Seeds

Dados de referência (tipos, status, categorias fixas) devem ser criados em `db/seeds.rb`
com `find_or_create_by!` para garantir idempotência.
