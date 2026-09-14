require 'sqlite3'
require_relative 'validacion_inputs_edit'
require_relative 'message_helper'
require_relative 'edit_validation'
require_relative 'constants'
def retrieve_battery_data(id)
  db = nil
  begin
    db = SQLite3::Database.open(NOMBRE_DB)
    db.execute("SELECT * FROM tabla_de_datos WHERE ID = ?", id).first
  rescue SQLite3::Exception => error
    puts "Error al recuperar datos de la batería: #{error.message}"
    nil
  ensure
    db.close if db
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
    return if @search_operation
    return if @processing_changed_fields
    @processing_changed_fields = true
    if changed_fields.all? { |field_data| field_data[:original] == field_data[:new] }
      show_message("No se realizaron cambios")
    else
      display_changed_fields(changed_fields)
      replace_data_in_database(changed_fields, id, comment)
      clear_entry_fields(edit_grid)
    end
  rescue StandardError => error
    puts "Error al procesar campos cambiados: #{error.message}"
  ensure
    @processing_changed_fields = false
  end
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
    puts "Error al mostrar campos cambiados: #{error.message}"
  end
end
