Rails.application.routes.draw do
  # ── Autenticação (Devise) ──────────────────────────────────────────────────
  devise_for :users

  # ── Tratamento de erros HTTP ───────────────────────────────────────────────
  match '/404', to: 'errors#not_found',             via: :all
  match '/422', to: 'errors#unprocessable_entity',  via: :all
  match '/500', to: 'errors#internal_server_error', via: :all
  match '/403', to: 'errors#unauthorized',          via: :all

  # ── Página inicial ─────────────────────────────────────────────────────────
  root 'home#index'

  # ── Usuários ───────────────────────────────────────────────────────────────
  resources :users, path: 'usuarios'

  # ── Administração ──────────────────────────────────────────────────────────
  resources :a_tipo_usuarios
  resources :a_status

  # ── Rotas do projeto (adicione abaixo) ─────────────────────────────────────
  # resources :exemplos

  # ── Health check (load balancer / uptime) ─────────────────────────────────
  get 'up' => 'rails/health#show', as: :rails_health_check
end
