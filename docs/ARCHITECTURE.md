# Arquitetura do WIP

## Stack

| Camada         | Tecnologia                             |
|----------------|----------------------------------------|
| Framework      | Ruby on Rails 7.2                      |
| Banco de dados | PostgreSQL                             |
| Autenticação   | Devise                                 |
| Autorização    | CanCanCan                              |
| Formulários    | Simple Form                            |
| Paginação      | Pagy (Bootstrap extras)                |
| Busca/Filtros  | Ransack                                |
| Soft delete    | Paranoia (`deleted_at`)                |
| Auditoria      | Paper Trail + concern `Auditable`      |
| Jobs assíncronos | Good Job (Postgres, sem Redis)       |
| Frontend       | Bootstrap 5 + Phosphor Icons + jQuery  |
| JS             | Hotwire (Turbo + Stimulus)             |
| Excel          | Caxlsx / Axlsx Rails                   |
| PDF            | Wicked PDF                             |

---

## Estrutura de diretórios relevante

```
app/
├── controllers/
│   ├── application_controller.rb   # Inclui todos os concerns
│   ├── errors_controller.rb        # 404 / 422 / 500 / 403
│   ├── home_controller.rb          # Dashboard
│   ├── users_controller.rb         # CRUD de usuários
│   └── concerns/
│       ├── authorization_handler.rb       # Rescue CanCan::AccessDenied
│       ├── devise_permitted_parameters.rb # Campos extras no Devise
│       └── layout_by_user.rb             # Layout por controller
│
├── models/
│   ├── current.rb                  # CurrentAttributes (Current.user)
│   ├── user.rb                     # Devise + Paranoia + PaperTrail
│   ├── a_tipo_usuario.rb           # Tipos: Admin, Gestor, Operador...
│   ├── a_status.rb                 # Status: Ativo, Inativo, Bloqueado...
│   ├── ability.rb                  # Router de abilities
│   ├── abilities/
│   │   ├── base_ability.rb         # Permissões mínimas compartilhadas
│   │   ├── admin_ability.rb        # can :manage, :all
│   │   ├── gestor_ability.rb       # Template p/ gestor
│   │   └── operador_ability.rb     # Template p/ operador
│   └── concerns/
│       └── auditable.rb            # auto created_by / updated_by
│
├── helpers/
│   ├── application_helper.rb       # Formatações PT-BR (CPF, CEP, moeda...)
│   ├── sidebar_helper.rb           # Classes CSS para menu ativo
│   └── users_helper.rb             # Badges de tipo e status
│
└── views/
    ├── layouts/
    │   ├── application.html.erb    # Layout principal (com sidebar)
    │   ├── devise_application.html.erb
    │   └── errors.html.erb         # Layout de erros (sem sidebar)
    ├── errors/                     # Páginas 404, 422, 500, 403
    ├── home/index.html.erb         # Dashboard
    ├── users/                      # CRUD de usuários
    └── shared/
        ├── _flash.html.erb         # Mensagens notice/alert
        ├── _navbar.html.erb        # Navbar com current_user
        ├── _context_nav.html.erb   # Breadcrumb reutilizável
        ├── _pagy.html.erb          # Componente de paginação
        └── sidebar/_sidebar.html.erb

config/
├── routes.rb                       # Devise + erros + users + admin
├── application.rb                  # Good Job + exceptions_app + PT-BR
└── initializers/
    ├── inflections.rb              # Inflexões PT-BR com prefixos de módulo
    └── pagy.rb                     # i18n + bootstrap, 6 por página

db/
├── migrate/
│   ├── 20260401000001_create_a_tipo_usuarios.rb
│   ├── 20260401000002_create_a_status.rb
│   └── 20260401000003_devise_create_users.rb
└── seeds.rb                        # Admin@123 + tipos + status padrão
```

---

## Padrão de módulos prefixados

O projeto usa prefixos para organizar modelos por domínio sem criar namespaces:

| Prefixo | Domínio           | Exemplos de models/tabelas         |
|---------|-------------------|------------------------------------|
| `a_`    | Administração     | `a_tipo_usuario`, `a_status`       |
| `g_`    | Geral / Geográfico| `g_municipio`, `g_estado`          |
| `f_`    | Financeiro        | `f_empresa`, `f_financeiro`        |
| `o_`    | Ordens/Operações  | `o_solicitacao`, `o_cotacao`       |
| `c_`    | (ex: Combustível) | `c_posto`, `c_combustivel`         |

Adicione prefixos novos conforme o domínio do projeto.

---

## Fluxo de autenticação/autorização

```
Request → ApplicationController
            ├── authenticate_user!        (Devise)
            ├── set_current_user          (Current.user = current_user)
            ├── set_paper_trail_whodunnit (PaperTrail)
            └── load_and_authorize_resource (CanCanCan por controller)
                    └── Ability#initialize
                            ├── admin?   → AdminAbility   (manage :all)
                            ├── gestor?  → GestorAbility  (defina as permissões)
                            └── else     → OperadorAbility (defina as permissões)
```

---

## Auditoria em dois níveis

1. **Auditable concern** — campos `created_by` / `updated_by` na tabela:
   ```ruby
   include Auditable  # adicione em qualquer model
   ```

2. **Paper Trail** — histórico completo de versões na tabela `versions`:
   ```ruby
   has_paper_trail  # adicione em qualquer model
   ```
