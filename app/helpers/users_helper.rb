module UsersHelper
  def badge_status_usuario(user)
    return content_tag(:span, 'Sem status', class: 'badge bg-secondary') if user.a_status.blank?

    css = case user.a_status.descricao.downcase
          when 'ativo'     then 'bg-success'
          when 'inativo'   then 'bg-secondary'
          when 'bloqueado' then 'bg-danger'
          else 'bg-warning text-dark'
          end

    content_tag(:span, user.a_status.descricao, class: "badge #{css}")
  end

  def badge_tipo_usuario(user)
    return content_tag(:span, 'Sem tipo', class: 'badge bg-secondary') if user.a_tipo_usuario.blank?

    css = case user.a_tipo_usuario.descricao.downcase
          when 'admin'    then 'bg-danger'
          when 'gestor'   then 'bg-primary'
          when 'operador' then 'bg-info text-dark'
          else 'bg-secondary'
          end

    content_tag(:span, user.a_tipo_usuario.descricao, class: "badge #{css}")
  end
end
