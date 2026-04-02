class UsersController < ApplicationController
  load_and_authorize_resource

  def index
    @q     = User.ransack(params[:q])
    @pagy, @users = pagy(@q.result)
  end

  def show; end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      redirect_to users_path, notice: 'Usuário cadastrado com sucesso!'
    else
      render :new, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotUnique => e
    aplicar_erro_de_unicidade(@user, e)
    render :new, status: :unprocessable_entity
  end

  def edit; end

  def update
    if @user.update(user_params)
      redirect_to users_path, notice: 'Usuário atualizado com sucesso!', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user.destroy
      redirect_to users_path, notice: 'Usuário excluído com sucesso.'
    else
      redirect_to users_path, alert: 'Não foi possível excluir o usuário.'
    end
  end

  private

  def user_params
    base = %i[nome email cpf telefone password password_confirmation foto_perfil]
    base += %i[a_tipo_usuario_id a_status_id] if current_user.admin?
    params.require(:user).permit(base)
  end

  def aplicar_erro_de_unicidade(user, exception)
    mensagem = exception.message.to_s
    if mensagem.include?('index_users_on_email')
      existente = User.with_deleted.find_by(email: user.email)
      if existente&.deleted_at.present?
        user.errors.add(:email, 'já pertence a um usuário excluído. Restaure o cadastro para reutilizar este e-mail.')
      else
        user.errors.add(:email, 'já está em uso')
      end
    else
      user.errors.add(:base, 'Já existe um registro com os mesmos dados únicos.')
    end
  end
end
