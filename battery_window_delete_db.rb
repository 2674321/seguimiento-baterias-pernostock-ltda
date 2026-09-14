require 'gtk3'
require 'sqlite3'
require 'time'
require_relative 'message_helper'
require_relative 'statistics_logic'
require_relative 'constants'
def eliminar_seleccion_bd(tree_view, list_store)
  selection = tree_view.selection
  iter = selection.selected
  return unless iter
  dialog = Gtk::MessageDialog.new(
    parent: nil,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::QUESTION,
    buttons: Gtk::ButtonsType::YES_NO,
    message: "¿Estás seguro de que deseas eliminar la selección de la base de datos?"
  )
  dialog.title = "Confirmación de Eliminación"
  dialog.set_position(Gtk::WindowPosition::CENTER)
  response = dialog.run
  if response == Gtk::ResponseType::YES
    id_bateria = iter[0]
    fecha_hora_eliminacion = Time.now.strftime("%Y-%m-%d %H:%M:%S")
    begin
      db = SQLite3::Database.open(NOMBRE_DB)
      db.execute("DELETE FROM tabla_de_datos WHERE ID = ?", id_bateria)
      list_store.remove(iter) if db.changes > 0
      UltimaOperacion.actualizar_ultima_operacion_realizada("Eliminación de batería: ID #{id_bateria} - #{fecha_hora_eliminacion}")
    rescue SQLite3::Exception => e
      puts "Error al eliminar la selección de la base de datos: #{e.message}"
    ensure
      db.close if db
    end
  else
    MessageHelper.show_message_window("Eliminación, cancelada")
  end
  dialog.destroy
end