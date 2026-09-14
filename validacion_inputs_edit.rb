require_relative 'message_helper'
require_relative 'field_validators'
require_relative 'constants'
require_relative 'edit_validation'
require_relative 'edit_window_history_data_insert_module'
module ValidationModule
  def validate_edited_fields(edited_fields)
    error_messages = []
    edited_fields.each do |column, value|
      if %w[VENDEDOR CLIENTE].include?(column)
        if value =~ /\d/
          error_messages << "#{column}: No debe contener números.\n Valor ingresado: #{value}"
        else
          unless FieldValidators.valid_client_or_vendor?(value)
            error_messages << "#{column}: Debe contener al menos un Nombre y Apellido y/o Nombre de la empresa, y solo caracteres alfabéticos.\n Valor ingresado: #{value}"
          end
        end
      elsif column == 'MOTIVO'
        unless FieldValidators.valid_motivo?(value)
          error_messages << "MOTIVO: Debe ser uno de los siguientes estados: Funcional (Devuelta pero sigue funcional), Defectuoso, Problema de fábrica, Daño en envío, Incompatible,Cambio de modelo, error en el pedido. Valor ingresado: #{value}"
        end
      elsif %w[RECEPCION FECHA_C FECHA_NC FECHA_ENVIO].include?(column)
        date_regex = /\A\d{4}\/\d{2}\/\d{2}\z/
        unless value.match?(date_regex)
          error_messages << "#{column}: Debe tener el formato AAAA/MM/DD. Valor ingresado: #{value}"
        else
          year, month, day = value.split('/').map(&:to_i)
          unless (FieldValidators::MIN_YEAR..FieldValidators::MAX_YEAR).include?(year) && (1..12).include?(month)
            error_messages << "#{column}: Año o mes fuera de rango, Por favor ingrese una fecha valida. Valor ingresado: #{value}"
          else
            max_days = Date.new(year, month, -1).day
            unless (1..max_days).include?(day)
              error_messages << "#{column}: Día fuera de rango para el mes y año proporcionados. Valor ingresado: #{value}"
            end
          end
        end
      elsif column == 'RECARGA'
        allowed_values = FieldValidators::RECARGA_STATES
        unless FieldValidators.valid_recarga?(value, allowed_values)
          error_messages << "RECARGA: Debe ser uno de los siguientes estados: #{allowed_values.join(', ')}. Valor ingresado: #{value}"
        end
      elsif column == 'NC'
        unless FieldValidators.valid_edit_positive_integers?(value)
          error_messages << "#{column}: Debe contener solo números. Valor ingresado: #{value}"
        end
      elsif %w[DESTINO MODELO SERIE FACTURA].include?(column)
        unless FieldValidators.valid_simple_text?(value)
          error_messages << "#{column}: No es un valor válido (solo letras, números, comas, guiones y barras inclinadas).\n Valor ingresado: #{value}"
        end
      elsif column == 'COMENTARIOS'
        unless FieldValidators.valid_comment?(value)
          if value.length > FieldValidators::MAX_COMMENT_LENGTH
            error_messages << "#{column}: El comentario no puede exceder los #{FieldValidators::MAX_COMMENT_LENGTH} caracteres. Valor ingresado: #{value}"
          else
            error_messages << "#{column}: El comentario no puede consistir solo de números. Valor ingresado: #{value}"
          end
        end
      end
    end
    if error_messages.empty?
      true
    else
      error_message = "Se encontraron los siguientes errores al validar los campos editados:\n#{error_messages.join("\n")}"
      MessageHelper.show_message_window(error_message)
      false
    end
  end
  def collect_edited_fields(edit_grid, id)
    edited_fields = {}
    Constants::TablaDeDatos::COLUMN_NAMES.each_with_index do |(_key, value), index|
      entry = edit_grid.get_child_at(1, index)
      entry_text = entry.text.to_s.strip
      original_value = @original_field_values.fetch(value, '').to_s.strip
      if entry.is_a?(Gtk::Entry) && entry_text != original_value && !entry_text.empty?
        edited_fields[value] = entry_text
      end
    end
    edited_fields
  rescue StandardError => error
    puts "Error al recoger campos editados: #{error.message}"
    {}
  end
end