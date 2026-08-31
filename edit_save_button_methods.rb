require_relative 'edit_validation'
def save_button_logic(comment, edit_grid, id)
  begin
    changed_fields = []
    invalid_fields = []
    invalid_fields << 'Motivo de la Edición' if comment.strip.empty?
    search_result = perform_search(edit_grid, id)
    if search_result.to_s.start_with?("Error", "Batería no encontrada")
      show_message_window(search_result)
    else
      collect_changed_fields(edit_grid, changed_fields)
      if invalid_fields.empty?
        process_changed_fields(changed_fields, id, edit_grid, comment)
      else
        handle_invalid_fields(invalid_fields)
      end
    end
  rescue StandardError => error
    puts "Error en la lógica del botón de guardar: #{error.message}"
  end
end
def collect_changed_fields(edit_grid, changed_fields)
  begin
    Constants::TablaDeDatos::COLUMN_NAMES.each_with_index do |(_key, value), index|
      entry = edit_grid.get_child_at(1, index)
      entry_text = entry.text.to_s.strip
      original_value = @original_field_values.fetch(value, '').to_s.strip
      if entry.is_a?(Gtk::Entry) && entry_text != original_value && !entry_text.empty?
        changed_fields << { field: value, original: original_value, new: entry_text }
      end
    end
    changed_fields.select! { |field_data| field_data[:original] != field_data[:new] }
  rescue StandardError => error
    puts "Error al recoger campos editados: #{error.message}"
  end
end
def replace_data_in_database(changed_fields, id, comment)
  begin
    fields_hash = changed_fields.each_with_object({}) do |field_data, hash|
      field = field_data[:field]
      new_value = field_data[:new]
      original_value = field_data[:original]
      hash[field] = new_value
      GuardarEnTablaDelHistorial.guardar_en_tabla_de_registro(id, field, original_value, new_value, comment)
    end
    REEMPLAZO_DE_DATOS.reemplazar_datos(id, fields_hash)
    @original_field_values = {}
  rescue StandardError => error
    puts "Error al reemplazar datos en la base de datos: #{error.message}"
  end
end
