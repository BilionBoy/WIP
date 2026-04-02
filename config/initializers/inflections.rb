# config/initializers/inflections.rb
#
# Inflexões para nomenclatura PT-BR com prefixos de módulo.
# Padrão: inflect.irregular 'modelo_singular', 'tabela_plural'
#
# CONVENÇÃO DO PROJETO:
#   a_ → Administração (usuários, perfis, status, cargos)
#   g_ → Geral        (geográficos, auxiliares)
#   [x]_ → Módulo     (ex: f_ = financeiro, o_ = ordens, c_ = combustível)
#
# Como adicionar:
#   inflect.irregular 'x_nome_no_singular', 'x_nomes_no_plural'
#   Exemplo: inflect.irregular 'o_ordem_servico', 'o_ordem_servicos'

ActiveSupport::Inflector.inflections(:en) do |inflect|
  # ─── MÓDULO ADMINISTRAÇÃO (A_) ───────────────────────────────────────────────
  inflect.irregular 'a_tipo_usuario',                    'a_tipo_usuarios'
  inflect.irregular 'a_status',                          'a_status'

  # Descomente e adapte conforme o projeto:
  # inflect.irregular 'a_unidade',                       'a_unidades'
  # inflect.irregular 'a_cargo',                         'a_cargos'
  # inflect.irregular 'a_papel',                         'a_papeis'
  # inflect.irregular 'a_permissao',                     'a_permissoes'
  # inflect.irregular 'a_papel_permissao',               'a_papeis_permissoes'
  # inflect.irregular 'a_tipo_unidade',                  'a_tipos_unidades'
  # inflect.irregular 'a_usuario_papel',                 'a_usuarios_papeis'

  # ─── MÓDULO GERAL (G_) ───────────────────────────────────────────────────────
  # inflect.irregular 'g_status',                        'g_status'
  # inflect.irregular 'g_pais',                          'g_paises'
  # inflect.irregular 'g_estado',                        'g_estados'
  # inflect.irregular 'g_municipio',                     'g_municipios'
  # inflect.irregular 'g_bairro',                        'g_bairros'

  # ─── OUTROS MÓDULOS ──────────────────────────────────────────────────────────
  # Adicione aqui as inflexões específicas do seu projeto:
  # inflect.irregular 'x_exemplo',                       'x_exemplos'
end
