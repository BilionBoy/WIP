module SidebarHelper
  # Retorna a classe CSS correta para o link ativo na sidebar.
  # Uso: class="nav-link <%= sidebar_active_class('users') %>"
  def sidebar_active_class(controller_name_param)
    'active' if controller_name == controller_name_param.to_s
  end

  # Retorna a classe CSS para seção expansível ativa.
  # Uso: class="nav-group-sub collapse <%= sidebar_section_active?('users', 'a_tipo_usuarios') %>"
  def sidebar_section_active?(*controller_names)
    'show' if controller_names.map(&:to_s).include?(controller_name)
  end
end
