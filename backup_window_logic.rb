require 'gtk3'
require 'fileutils'
require_relative 'database_loader'
def show_error_dialog(message)
  dialog = Gtk::MessageDialog.new(
    transient_for: nil,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::ERROR,
    buttons: Gtk::ButtonsType::CLOSE,
    message: message
  )
  dialog.set_position(Gtk::WindowPosition::CENTER)
  dialog.run
  dialog.destroy
end
def show_confirmation_dialog(window)
  dialog = Gtk::MessageDialog.new(
    transient_for: window,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::QUESTION,
    buttons: Gtk::ButtonsType::YES_NO,
    message: '¿Estás seguro de que quieres realizar la copia de seguridad?'
  )
  dialog.set_position(Gtk::WindowPosition::CENTER)
  response = dialog.run
  dialog.destroy
  response == Gtk::ResponseType::YES
end
