require 'gtk3'
module MessageHelper
  def self.show_message_window(message, main_window = nil)
    varyyy = 0
    message_dialog = Gtk::MessageDialog.new(
      parent: main_window,
      flags: Gtk::DialogFlags::MODAL,
      type: Gtk::MessageType::WARNING,
      buttons: Gtk::ButtonsType::OK,
      message: "Mensaje"
    )
    message_dialog.secondary_text = message
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
