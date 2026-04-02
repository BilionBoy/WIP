module ApplicationHelper
  include Pagy::Frontend
  include SidebarHelper

  # ─── Botão de submit inteligente ─────────────────────────────────────────────
  def btn_submit(form)
    text = form.object.new_record? ? 'Incluir' : 'Atualizar'
    icon_class = 'ph-paper-plane-tilt ms-1'
    button_tag(type: 'submit', class: 'btn btn-primary') do
      safe_join([text, content_tag(:i, '', class: icon_class)])
    end
  end

  # ─── Formatação de documentos ─────────────────────────────────────────────────
  def formatar_cpf(cpf)
    cpf.gsub(/(\d{3})(\d{3})(\d{3})(\d{2})/, '\1.\2.\3-\4') if cpf.present?
  end

  def formatar_cnpj(cnpj)
    cnpj.gsub(/(\d{2})(\d{3})(\d{3})(\d{4})(\d{2})/, '\1.\2.\3/\4-\5') if cnpj.present?
  end

  def formatar_cep(cep)
    cep.gsub(/(\d{5})(\d{3})/, '\1-\2') if cep.present?
  end

  def formatar_telefone(tel)
    return nil if tel.blank?

    digits = tel.gsub(/\D/, '')
    if digits.length == 11
      digits.gsub(/(\d{2})(\d{5})(\d{4})/, '(\1) \2-\3')
    else
      digits.gsub(/(\d{2})(\d{4})(\d{4})/, '(\1) \2-\3')
    end
  end

  # ─── Formatação de datas ──────────────────────────────────────────────────────
  def formatar_data(data)
    return nil if data.blank?

    case data
    when Date
      data.strftime('%d/%m/%Y')
    when String
      return nil unless data.match(%r{\A\d{2}/\d{2}/\d{4}\z})

      Date.strptime(data, '%d/%m/%Y').strftime('%d/%m/%Y')
    end
  end

  def formatar_data_hora(data_hora)
    data_hora.strftime('%d/%m/%Y às %H:%M') if data_hora.present?
  end

  def fim_do_dia(data_hora)
    data_hora.to_time.end_of_day if data_hora.present?
  end

  def formatar_mes(mes)
    meses = [
      nil,
      'Janeiro', 'Fevereiro', 'Março', 'Abril',
      'Maio', 'Junho', 'Julho', 'Agosto',
      'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ]
    meses[mes.to_i] || 'Mês inválido'
  end

  # ─── Seletores de data ────────────────────────────────────────────────────────
  def opcoes_meses
    [
      %w[Janeiro 01], %w[Fevereiro 02], %w[Março 03],
      %w[Abril 04],   %w[Maio 05],      %w[Junho 06],
      %w[Julho 07],   %w[Agosto 08],    %w[Setembro 09],
      %w[Outubro 10], %w[Novembro 11],  %w[Dezembro 12]
    ]
  end

  def opcoes_anos(inicio: 2024, fim: 2030)
    (inicio..fim).map(&:to_s)
  end

  # ─── Formatação de valores ────────────────────────────────────────────────────
  def formatar_moeda(value)
    number_to_currency(value.to_f, unit: 'R$', separator: ',', delimiter: '.', format: '%u %n') if value.present?
  end

  def formatar_valor_input(value)
    return '' if value.blank?

    number_with_precision(value.to_f, precision: 2, delimiter: '.', separator: ',')
  end

  def formatar_inteiro(value)
    value.to_i
  end

  # ─── Excel (XLSX) ─────────────────────────────────────────────────────────────
  def formatar_boolean_xlsx(value)
    value ? 'Sim' : 'Não'
  end
end
