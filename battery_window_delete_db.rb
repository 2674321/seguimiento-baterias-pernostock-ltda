def eliminar_seleccion_bd(tree_view, list_store)
  selection = tree_view.selection
  iter = selection.selected
  if iter
    deleted_battery_data = []
    num_columns = list_store.n_columns
    num_columns.times do |column_index|
      column_title = list_store.get_column_type(column_index).name.downcase
      value = list_store.get_value(iter, column_index)
      deleted_battery_data << "#{column_title}: #{value}"
    end
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
        db = SQLite3::Database.open 'base_de_datos.db'
        db.execute("DELETE FROM tabla_de_datos WHERE ID = ?", id_bateria)
        db.close
        list_store.remove(iter)
        UltimaOperacion.actualizar_ultima_operacion_realizada("Eliminación de batería: ID #{id_bateria} - #{fecha_hora_eliminacion}")
      rescue SQLite3::Exception => e
        puts "Error al eliminar la selección de la base de datos: #{e.message}"
      end
    else
      MessageHelper.show_message_window("Eliminación, cancelada")
    end
    dialog.destroy
  else
  end
end
