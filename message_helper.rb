require 'gtk3'
module MessageHelper
  def self.show_message_window(message, main_window = nil)
    message_dialog = Gtk::MessageDialog.new(
      parent: main_window,
      flags: Gtk::DialogFlags::MODAL,
      type: Gtk::MessageType::INFO,
      buttons: Gtk::ButtonsType::OK,
      message: message.to_s
    )
    message_dialog.title = "Mensaje"
    message_dialog.set_position(Gtk::WindowPosition::CENTER_ALWAYS)
    message_dialog.run
    message_dialog.destroy
  rescue ArgumentError => e
    puts "Error al mostrar el mensaje: #{e.message}"
  end

  def self.close_window(window)
    window.close
  end
end
def show_message_window(message, parent = nil)
  MessageHelper.show_message_window(message, parent || @current_edit_window)
end
def show_message(message)
  MessageHelper.show_message_window(message)
end
def handle_search_error(error)
  MessageHelper.show_message_window("Error en la búsqueda: #{error.message}")
end
def mostrar_ventana_de_error(errors)
  dialog = Gtk::MessageDialog.new(
    parent: @current_edit_window,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::WARNING,
    buttons: Gtk::ButtonsType::OK,
    message: "Errores:"
  )
  dialog.secondary_text = errors.each_with_index.map { |error_text, index| "#{index + 1}. #{error_text}" }.join("\n")
  dialog.run
  dialog.destroy
end