require_relative 'constants'
require_relative 'message_helper'
def validar_id(id)
  if id.nil? || id.empty? || !id.match?(/^\d+$/)
    raise ArgumentError, "El ID debe contener solo números"
  end
end
def perform_search(edit_grid, id)
  begin
    @original_field_values = {}
    @search_operation = true
    search_message = nil
    validar_id(id)
    battery_data = retrieve_battery_data(id)
    if battery_data.nil?
      search_message = "Batería no encontrada"
    else
      update_edit_grid_fields(edit_grid, battery_data)
      search_message = "Búsqueda exitosa"
    end
  rescue ArgumentError => e
    puts "Error en la búsqueda: #{e.message}"
    search_message = "Error en la búsqueda: #{e.message}"
  rescue SQLite3::Exception => error
    search_message = "Error en la búsqueda: #{error.message}"
  ensure
    @search_operation = false
    MessageHelper.show_message_window(search_message) unless search_message.nil?
  end
end