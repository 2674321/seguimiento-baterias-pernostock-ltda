require_relative 'validacion_inputs_edit'
require_relative 'message_helper'
require_relative 'edit_validation'
def retrieve_battery_data(id)
  begin
    db = SQLite3::Database.open(NOMBRE_DB)
    battery_data = db.execute("SELECT * FROM tabla_de_datos WHERE ID = ?", id).first
    db.close
    battery_data
  rescue SQLite3::Exception => error
    puts "Error al recuperar datos de la batería: #{error.message}"
    nil
  end
end
def update_edit_grid_fields(edit_grid, battery_data)
  begin
    Constants::TablaDeDatos::COLUMN_NAMES.each_with_index do |(_key, value), index|
      entry = edit_grid.get_child_at(1, index)
      entry_text = battery_data[index].to_s
      if entry.text.empty?
        entry.text = entry_text
      end
      @original_field_values[value] = entry_text
    end
  rescue StandardError => error
    puts "Error al actualizar campos en el grid: #{error.message}"
  end
end
def process_changed_fields(changed_fields, id, edit_grid, comment)
  begin
   # puts" Inicio process_changed_fields, changed fields#{changed_fields},id#{id},edit_grid#{edit_grid},comment#{comment}"
    return if @search_operation
    return if @processing_changed_fields
    @processing_changed_fields = true
    collect_edited_fields(edit_grid, id)
    if changed_fields.all? { |field_data| field_data[:original] == field_data[:new] }
      show_message("No se realizaron cambios")
    else
      display_changed_fields(changed_fields)
      collect_original_data(id)
      replace_data_in_database(changed_fields, id, comment)
      clear_entry_fields(edit_grid)
    end
    fecha_c_changed = changed_fields.any? { |field_data| field_data[:field] == 'FECHA_C' }
  rescue StandardError => error
    puts "Error al procesar campos cambiados: #{error.message}"
  ensure
    @processing_changed_fields = false
  end
end
def collect_original_data(id)
  begin
    @original_field_values = retrieve_battery_data(id)
  rescue StandardError => error
    puts "Error al recuperar datos originales: #{error.message}"
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
def required_fields_valid?(column_entries, required_fields)
  required_fields.all? { |field| !column_entries[field.to_sym].text.empty? }
end
def display_changed_fields(changed_fields)
  begin
    if changed_fields.empty?
      show_message("No se realizaron cambios")
    else
      fields_description = changed_fields.map do |field_data|
        field = field_data[:field]
        original_value = field_data[:original]
        new_value = field_data[:new]
        "Campo: #{field}, Original: #{original_value}, Nuevo: #{new_value}"
      end.join("\n")
      message = <<~MESSAGE
        Cambios realizados correctamente en los siguientes campos:
        #{fields_description}
      MESSAGE
      show_message(message)
    end
  rescue StandardError => error
    log_error("Error al mostrar campos cambiados: #{error.message}")
  end
end
