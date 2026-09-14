require 'gtk3'
module DialogHelper
  module_function

  def show_dialog(title, message, type: Gtk::MessageType::INFO, parent: nil, buttons: Gtk::ButtonsType::OK)
    dialog = Gtk::MessageDialog.new(
      parent: parent,
      flags: Gtk::DialogFlags::MODAL,
      type: type,
      buttons: buttons,
      message: message.to_s
    )
    dialog.title = title.to_s
    dialog.set_position(Gtk::WindowPosition::CENTER)
    response = dialog.run
    dialog.destroy
    response
  rescue ArgumentError => e
    puts "Error al mostrar el mensaje: #{e.message}"
    nil
  end

  def show_info(title, message, parent: nil)
    show_dialog(title, message, type: Gtk::MessageType::INFO, parent: parent)
  end

  def show_error(title, message, parent: nil)
    show_dialog(title, message, type: Gtk::MessageType::ERROR, parent: parent, buttons: Gtk::ButtonsType::CLOSE)
  end

  def show_warning(title, message, parent: nil, secondary: nil)
    dialog = Gtk::MessageDialog.new(
      parent: parent,
      flags: Gtk::DialogFlags::MODAL,
      type: Gtk::MessageType::WARNING,
      buttons: Gtk::ButtonsType::OK,
      message: title.to_s
    )
    dialog.title = title.to_s
    dialog.secondary_text = secondary if secondary
    dialog.set_position(Gtk::WindowPosition::CENTER)
    response = dialog.run
    dialog.destroy
    response
  rescue ArgumentError => e
    puts "Error al mostrar la advertencia: #{e.message}"
    nil
  end

  def show_confirmation(message, parent: nil)
    show_dialog('Confirmación', message, type: Gtk::MessageType::QUESTION, parent: parent, buttons: Gtk::ButtonsType::YES_NO) == Gtk::ResponseType::YES
  end
end