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
    handle_search_error(error)
    search_message = "Error en la búsqueda: #{error.message}"
  ensure
    @search_operation = false
    MessageHelper.show_message_window(search_message) unless search_message.nil?
  end
end
def handle_search_error(error)
  error_message = "Error de búsqueda: #{error.message}"
  error_window = Gtk::Window.new
  error_window.title = "Error de Búsqueda"
  error_window.set_default_size(300, 100)
  error_label = Gtk::Label.new(error_message)
  error_label.set_halign(Gtk::Align::CENTER)
  error_label.set_valign(Gtk::Align::CENTER)
  error_window.add(error_label)
  error_window.set_window_position(Gtk::WindowPosition::CENTER)
  error_window.show_all
end
def mostrar_ventana_de_error(errors)
  dialog = Gtk::MessageDialog.new(
    parent: @current_edit_window,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::WARNING,
    buttons: Gtk::ButtonsType::OK,
    message: "Errores:"
  )
  dialog.secondary_text = ""
  errors.each_with_index do |error, index|
    dialog.secondary_text += "#{index + 1}. #{error}\n"
  end
  dialog.run
  dialog.destroy
end
