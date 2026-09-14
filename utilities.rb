require 'gtk3'
require 'fileutils'
def show_message_dialog(title, message)
  dialog = Gtk::MessageDialog.new(
    parent: nil,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::INFO,
    buttons: Gtk::ButtonsType::OK,
    message: nil
  )
  dialog.title = title
  dialog.set_markup("<span size='medium' foreground='black'>#{message}</span>")
  dialog.window_position = Gtk::WindowPosition::CENTER
  dialog.run
  dialog.destroy
end