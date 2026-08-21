require_relative 'message_helper'
require_relative 'statistics_logic'
require_relative 'constants'
require_relative 'edit_save_button_methods'
require_relative 'edit_validation'
require_relative 'edit_window_history_data_insert_module'
require_relative 'edit_window_methods'
module ValidationModule
  def show_alert_dialog(message)
    puts "ALERTA: #{message}"
  end
  def validate_edited_fields(edited_fields)
    error_messages = []
    edited_fields.each do |column, value|
      if %w[VENDEDOR CLIENTE].include?(column)
        if value =~ /\d/
          error_messages << "#{column}: No debe contener números.\n Valor ingresado: #{value}"
        else
          names = value.split(' ')
          if names.length < 1 || names.any? { |name| name !~ /\A[^0-9!@#$%^&*()_+={}\[\]|\\:;"'<>,.?\/]+\z/ }
            error_messages << "#{column}: Debe contener al menos un Nombre y Apellido y/o Nombre de la empresa, y solo caracteres alfabéticos.\n Valor ingresado: #{value}"
          end
        end
      elsif column == 'MOTIVO'
        allowed_states = ["funcional","Funcional", "defectuoso", "Defectuoso", "problema de fábrica", "Problema de fábrica", "daño en envio","Daño en envio", "Daño en envío", "daño en envío", "Incompatible", "incompatible", "Error en el pedido", "error en el pedido", "Cambio de modelo", "cambio de modelo"]
        normalized_value = value.to_s.downcase.strip
        unless allowed_states.any? { |state| normalized_value.include?(state) } &&
               normalized_value.split.all? { |part| !part.empty? && part.match?(/\A[a-zA-Z]+\z/) }
          error_messages << "MOTIVO: Debe ser uno de los siguientes estados: Funcional (Devuelta pero sigue funcional), Defectuoso, Problema de fábrica, Daño en envío, Incompatible,Cambio de modelo, error en el pedido. Valor ingresado: #{value}"
        end
      elsif %w[RECEPCION FECHA_C FECHA_NC FECHA].include?(column)
        date_regex = /\A\d{4}\/\d{2}\/\d{2}\z/
        unless value.match?(date_regex)
          error_messages << "#{column}: Debe tener el formato AAAA/MM/DD. Valor ingresado: #{value}"
        else
          unless valid_combined_date?(value)
            error_messages << "#{column}: La fecha no es válida. Valor ingresado: #{value}"
          else
            date_parts = value.split('/')
            unless date_parts.length == 3
              error_messages << "#{column}: La fecha debe contener año, mes y día. Valor ingresado: #{value}"
            else
              year, month, day = date_parts.map(&:to_i)
              unless (1800..2050).include?(year) && (1..12).include?(month)
                error_messages << "#{column}: Año o mes fuera de rango, Por favor ingrese una fecha valida. Valor ingresado: #{value}"
              else
                max_days = Date.new(year, month, -1).day
                unless (1..max_days).include?(day)
                  error_messages << "#{column}: Día fuera de rango para el mes y año proporcionados. Valor ingresado: #{value}"
                end
              end
            end
          end
        end
      elsif column == 'RECARGA'
        allowed_values = ["cargado", "descargado", "en revision", "defectuoso","Cargado", "Descargado", "En revision", "Defectuoso", "En revisión"]
        normalized_value = value.to_s.downcase.strip
        normalized_allowed_values = allowed_values.map { |v| v.to_s.downcase.strip }
        unless normalized_value.empty? || normalized_allowed_values.include?(normalized_value)
          error_messages << "RECARGA: Debe ser uno de los siguientes estados: #{allowed_values.join(', ')}. Valor ingresado: #{value}"
        end
      elsif column == 'NC'
        unless value =~ /^\d+(\s\d+)*$/
          error_messages << "#{column}: Debe contener solo números. Valor ingresado: #{value}"
        end
      elsif column == 'DESTINO'
        unless value =~ /^[A-Za-z0-9\s,\-\/]+$/
          error_messages << "#{column}: No es un valor válido (solo letras, números, comas, guiones y barras inclinadas).\n Valor ingresado: #{value}"
        end
      elsif column == 'MODELO'
        unless value =~ /^[A-Za-z0-9\s,\-\/]+$/
          error_messages << "#{column}: No es un valor válido (solo letras, números, comas, guiones y barras inclinadas).\n Valor ingresado: #{value}"
        end
      elsif column == 'SERIE'
        unless value =~ /^[A-Za-z0-9\s,\-\/]+$/
          error_messages << "#{column}: No es un valor válido (solo letras, números, comas, guiones y barras inclinadas).\n  Valor ingresado: #{value}"
        end
      elsif column == 'FACTURA'
        unless value =~ /^[A-Za-z0-9\s,\-\/]+$/
          error_messages << "#{column}: No es un valor válido (solo letras, números, comas, guiones y barras inclinadas).\n Valor ingresado: #{value}"
        end
      elsif column == 'COMENTARIOS'
        if value.length > 255
          error_messages << "#{column}: El comentario no puede exceder los 255 caracteres. Valor ingresado: #{value}"
        elsif value =~ /\A\d+\z/
          error_messages << "#{column}: El comentario no puede consistir solo de números. Valor ingresado: #{value}"
        end
      end
    end
    if error_messages.empty?
      true
    else
      error_message = "Se encontraron los siguientes errores al validar los campos editados:\n#{error_messages.join("\n")}"
      MessageHelper.show_message_window(error_message)
      show_alert_dialog(error_message)
      false
    end
  end
  def collect_edited_fields(edit_grid, id)
    begin
      @edited_fields = {}
      Constants::TablaDeDatos::COLUMN_NAMES.each_with_index do |(_key, value), index|
        entry = edit_grid.get_child_at(1, index)
        entry_text = entry.text.to_s.strip
        original_value = @original_field_values.fetch(value, '').to_s.strip
        if entry.is_a?(Gtk::Entry) && entry_text != original_value && !entry_text.empty?
          @edited_fields[value] = entry_text
        end
      end
      @edited_fields
    rescue StandardError => error
    # puts "Error al recoger campos editados: #{error.message}"
    end
  end
end
