# Skill: Fluxo Operacional — Solicitação → Cotação → Proposta → OS → NF

Implemente o **fluxo operacional completo** no projeto atual, seguindo exatamente a arquitetura e os padrões do WIP.

Este fluxo é genérico e se aplica a qualquer sistema de gestão de serviços, manutenções, compras, atendimentos ou ordens de trabalho.

---

## ENTIDADES DO FLUXO

```
Solicitação (pedido de serviço)
     ↓  [gestor publica para cotação]
Cotação (concorrência / pedido de orçamento)
     ↓  [fornecedores enviam propostas]
Proposta (resposta do fornecedor com valor e itens)
     ↓  [gestor aprova a melhor proposta]
Ordem de Serviço (execução)
     ↓  [fornecedor executa e conclui]
Nota Fiscal (comprovante de pagamento)
```

---

## 1. MODELOS DE SUPORTE (tabelas de lookup)

Crie esses models com `acts_as_paranoid`, campo `descricao`, inflexões registradas.

### Prefixo recomendado: `o_` (operacional) ou o prefixo do domínio do projeto.

```
o_status_solicitacoes   → Status: Rascunho | Aguardando Cotação | Em Cotação | Concluída | Cancelada
o_status_cotacoes       → Status: Aberta | Publicada | Encerrada | Cancelada
o_status_propostas      → Status: Rascunho | Enviada | Aprovada | Recusada
o_status               → Status da OS: Aguardando Início | Em Andamento | Em Revisão | Concluída | Cancelada
o_status_nf            → Status NF: Pendente | Enviada | Aprovada | Repasse Confirmado
o_tipos_solicitacoes   → Tipos: Corretiva | Preventiva | Emergencial | Recall
o_urgencias            → Urgência: Baixa | Média | Alta | Crítica
o_visibilidades        → Visibilidade da cotação: Pública | Restrita | Privada
o_categorias_servicos  → Categorias: Peças | Mão de Obra | Misto
o_tipos_categorias_servicos → Tipos de categoria
```

### Migration padrão para tabelas de suporte:
```ruby
create_table :o_status_solicitacoes do |t|
  t.string :descricao, null: false
  t.string :created_by
  t.string :updated_by
  t.datetime :deleted_at
  t.timestamps
end
add_index :o_status_solicitacoes, :descricao, unique: true
```

### Model padrão de suporte:
```ruby
class OStatusSolicitacao < ApplicationRecord
  include Auditable
  acts_as_paranoid
  validates :descricao, presence: true, uniqueness: true
end
```

---

## 2. MODEL: Solicitação (`o_solicitacoes`)

### Campos completos:
```ruby
create_table :o_solicitacoes do |t|
  t.integer  :numero,                  null: false  # auto-seq via before_create
  t.string   :descricao
  t.text     :observacao
  t.integer  :km_reportado                          # km/hodômetro do recurso
  t.datetime :data_limite_publicacao               # prazo máximo para publicar cotação
  t.datetime :publicado_em                          # quando foi publicado (preenchido auto)
  t.decimal  :saldo_snapshot, precision: 15, scale: 2  # saldo do centro de custo no momento

  # FK obrigatórias — adapte ao domínio do projeto:
  t.bigint   :solicitante_id,           null: false  # user que abriu
  t.bigint   :publicado_por_id                       # user que publicou (opcional)
  t.bigint   :o_tipo_solicitacao_id
  t.bigint   :o_categoria_servico_id,   null: false
  t.bigint   :o_urgencia_id
  t.bigint   :o_status_solicitacao_id,  null: false

  # FK ao recurso principal do projeto (ex: veiculo, ativo, equipamento):
  t.bigint   :recurso_id,               null: false  # ex: g_veiculo_id

  # FK ao centro de custo / budget:
  t.bigint   :centro_custo_id,          null: false

  t.string   :created_by
  t.string   :updated_by
  t.datetime :deleted_at
  t.timestamps
end
```

### Model:
```ruby
class OSolicitacao < ApplicationRecord
  include Auditable
  acts_as_paranoid
  has_paper_trail

  # Auto-numerar
  before_create :set_numero

  belongs_to :solicitante,          class_name: 'User'
  belongs_to :publicado_por,        class_name: 'User', optional: true
  belongs_to :o_tipo_solicitacao,   optional: true
  belongs_to :o_categoria_servico
  belongs_to :o_urgencia,           optional: true
  belongs_to :o_status_solicitacao

  # Adapte ao recurso do projeto:
  # belongs_to :g_veiculo

  has_many :o_cotacoes, foreign_key: 'o_solicitacao_id'
  has_many :o_ordem_servicos, through: :o_cotacoes, source: :o_ordem_servico

  validates :descricao, presence: true

  # Status helpers
  def rascunho?         = o_status_solicitacao&.descricao&.downcase == 'rascunho'
  def aguardando?       = o_status_solicitacao&.descricao&.downcase == 'aguardando cotação'
  def em_cotacao?       = o_status_solicitacao&.descricao&.downcase == 'em cotação'
  def concluida?        = o_status_solicitacao&.descricao&.downcase == 'concluída'
  def cancelada?        = o_status_solicitacao&.descricao&.downcase == 'cancelada'

  private

  def set_numero
    self.numero = (OSolicitacao.unscoped.maximum(:numero) || 0) + 1
  end
end
```

---

## 3. MODEL: Cotação (`o_cotacoes`)

### Campos:
```ruby
create_table :o_cotacoes do |t|
  t.bigint   :o_solicitacao_id,   null: false
  t.bigint   :o_status_cotacao_id, null: false
  t.bigint   :o_visibilidade_id,  null: false
  t.datetime :data_expiracao
  t.string   :created_by
  t.string   :updated_by
  t.datetime :deleted_at
  t.timestamps
end
```

### Model:
```ruby
class OCotacao < ApplicationRecord
  include Auditable
  acts_as_paranoid
  has_paper_trail

  belongs_to :o_solicitacao
  belongs_to :o_status_cotacao
  belongs_to :o_visibilidade

  has_many   :o_cotacoes_itens,  foreign_key: 'o_cotacao_id', dependent: :destroy
  has_many   :o_propostas,       foreign_key: 'o_cotacao_id'

  accepts_nested_attributes_for :o_cotacoes_itens, allow_destroy: true, reject_if: :all_blank

  def aberta?    = o_status_cotacao&.descricao&.downcase == 'aberta'
  def publicada? = o_status_cotacao&.descricao&.downcase == 'publicada'
  def encerrada? = o_status_cotacao&.descricao&.downcase == 'encerrada'
end
```

---

## 4. MODEL: Item de Cotação (`o_cotacoes_itens`)

```ruby
create_table :o_cotacoes_itens do |t|
  t.bigint   :o_cotacao_id,          null: false
  t.bigint   :o_categoria_servico_id, null: false
  t.string   :descricao
  t.integer  :quantidade
  t.decimal  :valor_unitario, precision: 10, scale: 2
  t.string   :created_by
  t.string   :updated_by
  t.datetime :deleted_at
  t.timestamps
end
```

---

## 5. MODEL: Proposta (`o_propostas`)

```ruby
create_table :o_propostas do |t|
  t.bigint   :o_cotacao_id,           null: false
  t.bigint   :o_status_proposta_id,   null: false
  t.bigint   :usuario_envio_id,       null: false   # fornecedor que enviou
  # Se houver model de fornecedor/empresa:
  # t.bigint :f_empresa_fornecedora_id, null: false
  t.decimal  :valor_total,    precision: 15, scale: 2
  t.decimal  :valor_mao_obra, precision: 15, scale: 2, default: 0
  t.integer  :prazo_execucao_dias
  t.datetime :validade_proposta
  t.integer  :versao, default: 1
  t.text     :observacao
  t.datetime :deleted_at
  t.timestamps
end
```

### Model:
```ruby
class OProposta < ApplicationRecord
  acts_as_paranoid
  has_paper_trail

  belongs_to :o_cotacao
  belongs_to :o_status_proposta
  belongs_to :usuario_envio, class_name: 'User'
  # belongs_to :f_empresa_fornecedora

  has_many :o_propostas_itens, foreign_key: 'o_proposta_id', dependent: :destroy
  has_one  :o_ordem_servico,   foreign_key: 'o_proposta_id'

  accepts_nested_attributes_for :o_propostas_itens, allow_destroy: true, reject_if: :all_blank

  def rascunho? = o_status_proposta&.descricao&.downcase == 'rascunho'
  def enviada?  = o_status_proposta&.descricao&.downcase == 'enviada'
  def aprovada? = o_status_proposta&.descricao&.downcase == 'aprovada'
  def recusada? = o_status_proposta&.descricao&.downcase == 'recusada'
end
```

---

## 6. MODEL: Item de Proposta (`o_propostas_itens`)

```ruby
create_table :o_propostas_itens do |t|
  t.bigint   :o_proposta_id,   null: false
  t.bigint   :o_cotacao_item_id           # referência ao item da cotação
  t.decimal  :quantidade,    precision: 10, scale: 2, default: 0
  t.decimal  :valor_unitario, precision: 15, scale: 2, default: 0
  t.decimal  :total_item,     precision: 15, scale: 2, default: 0
  t.string   :observacao
  t.string   :created_by
  t.string   :updated_by
  t.datetime :deleted_at
  t.timestamps
end
```

---

## 7. MODEL: Ordem de Serviço (`o_ordem_servicos`)

```ruby
create_table :o_ordem_servicos do |t|
  t.string   :numero_os, null: false           # único, gerado automaticamente
  t.bigint   :o_proposta_id, null: false
  t.bigint   :o_status_id,   null: false

  # FK ao fornecedor / executor (adapte):
  # t.bigint :f_empresa_fornecedora_id, null: false

  # FK ao recurso (adapte):
  # t.bigint :g_veiculo_id, null: false

  # Itens previstos vs executados (JSON flexível):
  t.json     :itens_previstos,  default: []
  t.json     :itens_executados, default: []

  t.datetime :data_inicio_prevista
  t.datetime :data_termino_prevista
  t.datetime :data_inicio_real
  t.datetime :data_termino_real

  t.decimal  :custo_real, precision: 15, scale: 2, default: 0

  t.bigint   :validado_por_id
  t.datetime :validado_em

  t.text     :observacoes
  t.string   :created_by
  t.string   :updated_by
  t.datetime :deleted_at
  t.timestamps
end
add_index :o_ordem_servicos, :numero_os, unique: true
```

### Model:
```ruby
class OOrdemServico < ApplicationRecord
  include Auditable
  acts_as_paranoid
  has_paper_trail

  before_create :gerar_numero_os

  belongs_to :o_proposta
  belongs_to :o_status
  belongs_to :validado_por, class_name: 'User', optional: true

  has_many :o_notas_fiscais, foreign_key: 'o_ordem_servico_id'

  # Status helpers
  def aguardando_inicio? = o_status&.descricao&.downcase == 'aguardando início'
  def em_andamento?      = o_status&.descricao&.downcase == 'em andamento'
  def em_revisao?        = o_status&.descricao&.downcase == 'em revisão'
  def concluida?         = o_status&.descricao&.downcase == 'concluída'
  def cancelada?         = o_status&.descricao&.downcase == 'cancelada'

  private

  def gerar_numero_os
    ano  = Date.today.year.to_s.last(2)
    seq  = OOrdemServico.unscoped.where("numero_os LIKE ?", "OS#{ano}%").count + 1
    self.numero_os = "OS#{ano}#{seq.to_s.rjust(5, '0')}"
  end
end
```

---

## 8. MODEL: Nota Fiscal (`o_notas_fiscais`)

```ruby
create_table :o_notas_fiscais do |t|
  t.bigint   :o_ordem_servico_id, null: false
  t.bigint   :o_status_nf_id
  t.string   :numero
  t.date     :data_emissao
  t.decimal  :valor_total, precision: 15, scale: 2
  t.string   :created_by
  t.string   :updated_by
  t.datetime :deleted_at
  t.timestamps
end
```

---

## 9. CONTROLLERS COMPLETOS

### OSolicitacoesController (padrão)
```ruby
class OSolicitacoesController < ApplicationController
  load_and_authorize_resource

  def index
    @q = OSolicitacao.ransack(params[:q])
    @pagy, @o_solicitacoes = pagy(@q.result.includes(:o_status_solicitacao, :solicitante))
  end

  def show; end
  def new;  @o_solicitacao = OSolicitacao.new; end
  def edit; end

  def create
    @o_solicitacao = OSolicitacao.new(solicitacao_params)
    @o_solicitacao.solicitante = current_user
    @o_solicitacao.o_status_solicitacao = OStatusSolicitacao.find_by!(descricao: 'Rascunho')
    if @o_solicitacao.save
      redirect_to o_solicitacoes_path, notice: 'Solicitação criada!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @o_solicitacao.update(solicitacao_params)
      redirect_to o_solicitacoes_path, notice: 'Solicitação atualizada!', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @o_solicitacao.destroy
    redirect_to o_solicitacoes_path, notice: 'Solicitação excluída.'
  end

  private

  def solicitacao_params
    params.require(:o_solicitacao).permit(
      :descricao, :observacao, :km_reportado, :data_limite_publicacao,
      :o_tipo_solicitacao_id, :o_categoria_servico_id, :o_urgencia_id
      # + FKs do recurso e centro de custo do projeto
    )
  end
end
```

### OCotacoesController — com ação de publicar
```ruby
class OCotacoesController < ApplicationController
  load_and_authorize_resource

  def index
    @q = OCotacao.ransack(params[:q])
    @pagy, @o_cotacoes = pagy(@q.result)
  end

  def show; end
  def new;  @o_cotacao = OCotacao.new; end
  def edit; end

  def create
    @o_cotacao = OCotacao.new(cotacao_params)
    @o_cotacao.o_status_cotacao = OStatusCotacao.find_by!(descricao: 'Aberta')
    if @o_cotacao.save
      redirect_to o_cotacoes_path, notice: 'Cotação criada!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # POST /o_cotacoes/:id/publicar
  def publicar
    status_publicada = OStatusCotacao.find_by!(descricao: 'Publicada')
    status_em_cotacao = OStatusSolicitacao.find_by!(descricao: 'Em Cotação')

    if @o_cotacao.update(o_status_cotacao: status_publicada, data_expiracao: cotacao_params[:data_expiracao])
      @o_cotacao.o_solicitacao.update!(
        publicado_em: Time.current,
        publicado_por: current_user,
        o_status_solicitacao: status_em_cotacao
      )
      redirect_to o_cotacoes_path, notice: 'Cotação publicada para fornecedores!'
    else
      redirect_to o_cotacao_path(@o_cotacao), alert: 'Erro ao publicar.'
    end
  end

  def update
    if @o_cotacao.update(cotacao_params)
      redirect_to o_cotacoes_path, notice: 'Cotação atualizada!', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @o_cotacao.destroy
    redirect_to o_cotacoes_path, notice: 'Cotação excluída.'
  end

  private

  def cotacao_params
    params.require(:o_cotacao).permit(
      :o_solicitacao_id, :o_visibilidade_id, :data_expiracao,
      o_cotacoes_itens_attributes: [:id, :descricao, :o_categoria_servico_id, :quantidade, :valor_unitario, :_destroy]
    )
  end
end
```

### OPropostasController — com aprovar/recusar
```ruby
class OPropostasController < ApplicationController
  load_and_authorize_resource

  def index
    @q = OProposta.ransack(params[:q])
    @pagy, @o_propostas = pagy(@q.result)
  end

  def show; end
  def new;  @o_proposta = OProposta.new; end

  def create
    @o_proposta = OProposta.new(proposta_params)
    @o_proposta.usuario_envio   = current_user
    @o_proposta.o_status_proposta = OStatusProposta.find_by!(descricao: 'Rascunho')
    if @o_proposta.save
      redirect_to o_propostas_path, notice: 'Proposta criada!'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # POST /o_propostas/:id/aprovar
  def aprovar
    status_aprovada  = OStatusProposta.find_by!(descricao: 'Aprovada')
    status_recusada  = OStatusProposta.find_by!(descricao: 'Recusada')
    status_os        = OStatus.find_by!(descricao: 'Aguardando Início')

    ActiveRecord::Base.transaction do
      # Recusa as demais propostas da mesma cotação
      @o_proposta.o_cotacao.o_propostas.where.not(id: @o_proposta.id).each do |p|
        p.update!(o_status_proposta: status_recusada)
      end

      # Aprova esta proposta
      @o_proposta.update!(o_status_proposta: status_aprovada)

      # Gera a OS
      OOrdemServico.create!(
        o_proposta: @o_proposta,
        o_status:   status_os,
        itens_previstos: @o_proposta.o_propostas_itens.map { |i|
          { descricao: i.o_cotacao_item&.descricao, quantidade: i.quantidade, valor: i.valor_unitario }
        }
      )
    end

    redirect_to o_propostas_path, notice: 'Proposta aprovada! OS gerada automaticamente.'
  rescue ActiveRecord::RecordInvalid => e
    redirect_to o_proposta_path(@o_proposta), alert: "Erro: #{e.message}"
  end

  # POST /o_propostas/:id/recusar
  def recusar
    status_recusada = OStatusProposta.find_by!(descricao: 'Recusada')
    @o_proposta.update!(o_status_proposta: status_recusada)
    redirect_to o_propostas_path, notice: 'Proposta recusada.'
  end

  private

  def proposta_params
    params.require(:o_proposta).permit(
      :o_cotacao_id, :valor_total, :valor_mao_obra, :prazo_execucao_dias,
      :validade_proposta, :observacao,
      o_propostas_itens_attributes: [:id, :o_cotacao_item_id, :quantidade, :valor_unitario, :total_item, :observacao, :_destroy]
    )
  end
end
```

### OOrdemServicosController — ações de ciclo de vida
```ruby
class OOrdemServicosController < ApplicationController
  load_and_authorize_resource

  def index
    @q = OOrdemServico.ransack(params[:q])
    @pagy, @o_ordem_servicos = pagy(@q.result)
  end

  def show; end

  # PATCH /o_ordem_servicos/:id/finalizar
  def finalizar
    status = OStatus.find_by!(descricao: 'Em Andamento')
    @o_ordem_servico.update!(o_status: status, data_inicio_real: Time.current)
    redirect_to o_ordem_servico_path(@o_ordem_servico), notice: 'OS em andamento.'
  end

  # PATCH /o_ordem_servicos/:id/marcar_em_revisao
  def marcar_em_revisao
    status = OStatus.find_by!(descricao: 'Em Revisão')
    @o_ordem_servico.update!(o_status: status)
    redirect_to o_ordem_servico_path(@o_ordem_servico), notice: 'OS em revisão.'
  end

  # PATCH /o_ordem_servicos/:id/validar_servico
  def validar_servico
    status = OStatus.find_by!(descricao: 'Concluída')
    @o_ordem_servico.update!(
      o_status:    status,
      validado_por: current_user,
      validado_em:  Time.current,
      data_termino_real: Time.current
    )
    redirect_to o_ordem_servico_path(@o_ordem_servico), notice: 'Serviço validado!'
  end

  # PATCH /o_ordem_servicos/:id/confirmar_pagamento
  def confirmar_pagamento
    status_nf = OStatusNf.find_by!(descricao: 'Aprovada')
    @o_ordem_servico.o_notas_fiscais.last&.update!(o_status_nf: status_nf)
    redirect_to o_ordem_servico_path(@o_ordem_servico), notice: 'Pagamento confirmado!'
  end
end
```

---

## 10. ROTAS

```ruby
# config/routes.rb — adicione dentro do bloco draw:

resources :o_tipos_solicitacoes
resources :o_status_solicitacoes
resources :o_status_cotacoes
resources :o_status_propostas
resources :o_status        # status das OS
resources :o_status_nf
resources :o_urgencias
resources :o_visibilidades
resources :o_categorias_servicos
resources :o_tipos_categorias_servicos

resources :o_solicitacoes

resources :o_cotacoes do
  member do
    post :publicar
  end
end

resources :o_propostas do
  member do
    post :aprovar
    post :recusar
    get  :pdf
  end
end

resources :o_ordem_servicos, only: [:index, :show] do
  member do
    patch :finalizar
    patch :marcar_em_revisao
    patch :validar_servico
    patch :confirmar_pagamento
  end
end

resources :o_notas_fiscais, only: [:index, :new, :create, :show]
```

---

## 11. INFLEXÕES (adicionar em inflections.rb)

```ruby
inflect.irregular 'o_status_solicitacao',     'o_status_solicitacoes'
inflect.irregular 'o_status_cotacao',         'o_status_cotacoes'
inflect.irregular 'o_status_proposta',        'o_status_propostas'
inflect.irregular 'o_status',                 'o_status'
inflect.irregular 'o_status_nf',              'o_status_nf'
inflect.irregular 'o_tipo_solicitacao',       'o_tipos_solicitacoes'
inflect.irregular 'o_tipo_categoria_servico', 'o_tipos_categorias_servicos'
inflect.irregular 'o_categoria_servico',      'o_categorias_servicos'
inflect.irregular 'o_urgencia',               'o_urgencias'
inflect.irregular 'o_visibilidade',           'o_visibilidades'
inflect.irregular 'o_solicitacao',            'o_solicitacoes'
inflect.irregular 'o_cotacao',                'o_cotacoes'
inflect.irregular 'o_cotacao_item',           'o_cotacoes_itens'
inflect.irregular 'o_proposta',               'o_propostas'
inflect.irregular 'o_proposta_item',          'o_propostas_itens'
inflect.irregular 'o_ordem_servico',          'o_ordem_servicos'
inflect.irregular 'o_nota_fiscal',            'o_notas_fiscais'
```

---

## 12. SEEDS DO FLUXO (adicionar ao seeds.rb)

```ruby
# Status Solicitação
%w[Rascunho "Aguardando Cotação" "Em Cotação" Concluída Cancelada].each do |d|
  OStatusSolicitacao.find_or_create_by!(descricao: d)
end

# Status Cotação
%w[Aberta Publicada Encerrada Cancelada].each do |d|
  OStatusCotacao.find_or_create_by!(descricao: d)
end

# Status Proposta
%w[Rascunho Enviada Aprovada Recusada].each do |d|
  OStatusProposta.find_or_create_by!(descricao: d)
end

# Status OS
["Aguardando Início", "Em Andamento", "Em Revisão", "Concluída", "Cancelada"].each do |d|
  OStatus.find_or_create_by!(descricao: d)
end

# Status NF
%w[Pendente Enviada Aprovada "Repasse Confirmado"].each do |d|
  OStatusNf.find_or_create_by!(descricao: d)
end

# Tipos de solicitação
%w[Corretiva Preventiva Emergencial Recall].each do |d|
  OTipoSolicitacao.find_or_create_by!(descricao: d)
end

# Urgências
%w[Baixa Média Alta Crítica].each do |d|
  OUrgencia.find_or_create_by!(descricao: d)
end

# Visibilidades
%w[Pública Restrita Privada].each do |d|
  OVisibilidade.find_or_create_by!(descricao: d)
end

# Categorias
%w[Peças "Mão de Obra" Misto].each do |d|
  OCategoriaServico.find_or_create_by!(descricao: d)
end
```

---

## 13. SIDEBAR — itens de menu do fluxo

```erb
<%# Módulo Operacional %>
<li class="nav-item nav-item-submenu">
  <a href="#" class="nav-link <%= sidebar_section_active?('o_solicitacoes', 'o_cotacoes', 'o_propostas', 'o_ordem_servicos', 'o_notas_fiscais') %>">
    <i class="ph-clipboard-text"></i>
    <span>Operacional</span>
  </a>
  <ul class="nav nav-group-sub collapse <%= sidebar_section_active?('o_solicitacoes', 'o_cotacoes', 'o_propostas', 'o_ordem_servicos', 'o_notas_fiscais') %>">
    <li class="nav-item">
      <%= link_to o_solicitacoes_path, class: "nav-link #{sidebar_active_class('o_solicitacoes')}" do %>
        <i class="ph-note-pencil"></i> <span>Solicitações</span>
      <% end %>
    </li>
    <li class="nav-item">
      <%= link_to o_cotacoes_path, class: "nav-link #{sidebar_active_class('o_cotacoes')}" do %>
        <i class="ph-currency-dollar"></i> <span>Cotações</span>
      <% end %>
    </li>
    <li class="nav-item">
      <%= link_to o_propostas_path, class: "nav-link #{sidebar_active_class('o_propostas')}" do %>
        <i class="ph-envelope-open"></i> <span>Propostas</span>
      <% end %>
    </li>
    <li class="nav-item">
      <%= link_to o_ordem_servicos_path, class: "nav-link #{sidebar_active_class('o_ordem_servicos')}" do %>
        <i class="ph-wrench"></i> <span>Ordens de Serviço</span>
      <% end %>
    </li>
    <li class="nav-item">
      <%= link_to o_notas_fiscais_path, class: "nav-link #{sidebar_active_class('o_notas_fiscais')}" do %>
        <i class="ph-receipt"></i> <span>Notas Fiscais</span>
      <% end %>
    </li>
  </ul>
</li>
```

---

## 14. ABILITIES

```ruby
# Em gestor_ability.rb (quem gerencia o fluxo):
main_ability.can :manage, [OSolicitacao, OCotacao, OOrdemServico]
main_ability.can :read,   [OProposta, ONotaFiscal]
main_ability.can :aprovar, OProposta
main_ability.can :validar_servico, OOrdemServico

# Em operador_ability.rb (quem executa):
main_ability.can :read,   [OCotacao, OOrdemServico]
main_ability.can :create, OProposta
main_ability.can :manage, ONotaFiscal
```

---

## 15. DIAGRAMA DO FLUXO DE STATUS

```
SOLICITAÇÃO:  Rascunho → Aguardando Cotação → Em Cotação → Concluída
                                                          ↘ Cancelada

COTAÇÃO:      Aberta → Publicada → Encerrada
                                 ↘ Cancelada

PROPOSTA:     Rascunho → Enviada → Aprovada
                                 ↘ Recusada

OS:           Aguardando Início → Em Andamento → Em Revisão → Concluída
                                                            ↘ Cancelada

NF:           Pendente → Enviada → Aprovada → Repasse Confirmado
```

---

## INSTRUÇÃO DE IMPLEMENTAÇÃO

Ao receber este comando, implemente o fluxo completo acima adaptando ao domínio do projeto atual:

1. **Adapte os nomes** — se o projeto trata de "atendimentos" em vez de "serviços", renomeie. O fluxo é o mesmo.
2. **Adapte as FKs** — substitua `g_veiculo_id` pelo recurso principal do projeto.
3. **Crie as migrations** na ordem correta (suporte → solicitação → cotação → proposta → OS → NF).
4. **Adicione as inflexões** em `config/initializers/inflections.rb`.
5. **Popule os seeds** com todos os status/tipos listados.
6. **Adicione os itens na sidebar**.
7. **Defina as abilities** por perfil de usuário.
8. **Crie as views** seguindo o padrão das views de `users/` (context_nav, card, table, form, pagy).
