# db/seeds.rb
# Dados base que todo projeto precisa. Rode com: bin/rails db:seed

puts '== Tipos de usuário ======================'
tipos = %w[Admin Gestor Operador]
tipos.each do |desc|
  ATipoUsuario.find_or_create_by!(descricao: desc)
  puts "  ✓ #{desc}"
end

puts '== Status ================================='
status_list = %w[Ativo Inativo Bloqueado]
status_list.each do |desc|
  AStatus.find_or_create_by!(descricao: desc)
  puts "  ✓ #{desc}"
end

puts '== Usuários de teste ======================'
status_ativo = AStatus.find_by!(descricao: 'Ativo')

[
  { nome: 'Administrador',  email: 'admin@template.com',    cpf: '00000000001', tipo: 'Admin',    senha: 'Admin@123'    },
  { nome: 'Gestor Teste',   email: 'gestor@template.com',   cpf: '00000000002', tipo: 'Gestor',   senha: 'Gestor@123'   },
  { nome: 'Operador Teste', email: 'operador@template.com', cpf: '00000000003', tipo: 'Operador', senha: 'Operador@123' },
].each do |dados|
  tipo = ATipoUsuario.find_by!(descricao: dados[:tipo])

  User.find_or_create_by!(email: dados[:email]) do |u|
    u.nome           = dados[:nome]
    u.cpf            = dados[:cpf]
    u.telefone       = '00000000000'
    u.password       = dados[:senha]
    u.a_tipo_usuario = tipo
    u.a_status       = status_ativo
  end

  puts "  ✓ #{dados[:email]} / #{dados[:senha]} [#{dados[:tipo]}]"
end

puts ''
puts '== Seeds concluídos! ======================'
puts ''
puts '  Usuários disponíveis:'
puts '    admin@template.com    / Admin@123    (Admin)'
puts '    gestor@template.com   / Gestor@123   (Gestor)'
puts '    operador@template.com / Operador@123 (Operador)'
