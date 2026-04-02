# Setup — Como iniciar um novo projeto a partir do WIP

## 1. Clonar o template

```bash
git clone https://github.com/BilionBoy/WIP.git nome-do-projeto
cd nome-do-projeto
```

## 2. Renomear o módulo da aplicação

Abra `config/application.rb` e renomeie `MenuxT` para o nome do projeto:

```ruby
module NomeDoSeuProjeto
  class Application < Rails::Application
    ...
  end
end
```

## 3. Instalar dependências

```bash
bundle install
```

## 4. Configurar o banco de dados

```bash
cp config/database.yml.example config/database.yml  # se existir
# Edite database.yml com as credenciais do projeto

bin/rails db:create
bin/rails db:migrate
bin/rails db:seed
```

Após o seed, acesse com:
- **E-mail:** `admin@template.com`
- **Senha:** `Admin@123`

## 5. Iniciar o servidor

```bash
bin/rails server
```

Acesse: `http://localhost:3000`

---

## Usuários de teste (após seed)

| E-mail                    | Senha          | Tipo     |
|---------------------------|----------------|----------|
| admin@template.com        | Admin@123      | Admin    |
| gestor@template.com       | Gestor@123     | Gestor   |
| operador@template.com     | Operador@123   | Operador |

---

## Banco de dados: MySQL para MVPs, PostgreSQL para produção

O WIP usa **PostgreSQL por padrão** (necessário para o Good Job).

### Opção 1 — MVP rápido com MySQL (sem jobs assíncronos)

Se não precisar de Good Job, você pode usar MySQL:

**Gemfile:**
```ruby
gem 'mysql2', '~> 0.5'
# remova ou comente: gem 'good_job'
```

**config/database.yml:**
```yaml
default: &default
  adapter: mysql2
  encoding: utf8mb4
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>
  username: root
  password: <%= ENV['DB_PASSWORD'] %>
  host: localhost

development:
  <<: *default
  database: nome_do_projeto_development

test:
  <<: *default
  database: nome_do_projeto_test

production:
  <<: *default
  database: nome_do_projeto_production
  username: <%= ENV['DB_USERNAME'] %>
  password: <%= ENV['DB_PASSWORD'] %>
  host: <%= ENV['DB_HOST'] %>
```

**config/application.rb** — remover as linhas do Good Job:
```ruby
# Remover:
# config.active_job.queue_adapter = :good_job
# config.good_job.execution_mode  = :async
```

### Opção 2 — PostgreSQL (padrão, recomendado para produção)

Já configurado no WIP. Garante:
- Good Job (jobs assíncronos sem Redis)
- Arrays e JSON nativos
- Full-text search nativo
- Performance superior em produção

### Migrando de MySQL para PostgreSQL

1. Exporte os dados: `mysqldump -u root -p banco > dump.sql`
2. Converta o dump (ferramenta: `pgloader` — faz automaticamente)
3. Troque a gem e o `database.yml`
4. Rode `bin/rails db:migrate`

```bash
# Com pgloader instalado:
pgloader mysql://user:pass@localhost/banco postgresql://user:pass@localhost/banco
```

---

## Checklist pós-clone

- [ ] Renomear módulo em `config/application.rb`
- [ ] Atualizar título em `app/views/layouts/application.html.erb` e `devise_application.html.erb`
- [ ] Substituir logos em `public/layout/assets/img/`
- [ ] Trocar cores do tema (`#005171`) em `_navbar.html.erb` e `_sidebar.html.erb`
- [ ] Adicionar inflexões específicas do projeto em `config/initializers/inflections.rb`
- [ ] Configurar variáveis de ambiente (`.env`)
- [ ] Adicionar módulos do projeto nas rotas (`config/routes.rb`)
- [ ] Definir abilities por perfil em `app/models/abilities/`
- [ ] Adicionar itens de menu na sidebar (`app/views/shared/sidebar/_sidebar.html.erb`)
- [ ] Se usar MySQL: trocar gem `pg` → `mysql2`, remover Good Job, atualizar `database.yml`
- [ ] Para o fluxo de serviços/ordens: invocar `/fluxo-operacional` e pedir à Claude a implementação
