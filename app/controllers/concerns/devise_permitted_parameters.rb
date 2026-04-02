module DevisePermittedParameters
  extend ActiveSupport::Concern

  included do
    before_action :configure_permitted_parameters, if: :devise_controller?
  end

  protected

  def configure_permitted_parameters
    # Campos extras além de email + password que o Devise deve aceitar.
    # Adicione aqui os campos da sua tabela users:
    keys = %i[nome telefone cpf a_tipo_usuario_id a_status_id]

    devise_parameter_sanitizer.permit(:sign_up,         keys: keys)
    devise_parameter_sanitizer.permit(:account_update,  keys: keys)
  end
end
