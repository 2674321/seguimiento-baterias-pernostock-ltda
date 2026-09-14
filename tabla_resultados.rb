require 'gtk3'
require 'sqlite3'
require_relative 'constants'
require_relative 'database_operations'
require_relative 'statistics_logic'
require_relative 'message_helper'
require_relative 'history_window_invert_order'

def obtener_registros_tabla_datos
  db = setup_database
  begin
    registros = db.execute('SELECT * FROM tabla_de_datos')
    registros.map { |fila| fila.map(&:to_s) }
  rescue SQLite3::Exception => e
    puts "Error al obtener los datos de la tabla: #{e.message}"
    nil
  ensure
    db.close if db
  end
end

def poblar_list_store(list_store, registros)
  list_store.clear
  return if registros.nil?
  registros.each do |fila|
    iter = list_store.append
    fila.each_with_index { |valor, i| iter[i] = valor }
  end
rescue StandardError => e
  puts "Error al poblar la tabla de resultados: #{e.message}"
  puts e.backtrace
end

def recargar_tabla_baterias(list_store, status_label = nil)
  registros = obtener_registros_tabla_datos
  return 0 if registros.nil?
  poblar_list_store(list_store, registros)
  @linea_divisoria_agregada = false
  if status_label
    status_label.markup = "<b>Mostrando #{registros.size} batería(s)</b> en la base de datos."
  end
  registros.size
end

def agregar_a_favoritos(tree_view, list_store)
  selection = tree_view.selection
  if (iter = selection.selected)
    num_columns = list_store.n_columns
    values = []
    num_columns.times do |column|
      values << iter.get_value(column)
    end
    list_store.remove(iter)
    if !@linea_divisoria_agregada
      new_iter_favoritos = list_store.prepend
      list_store.set_value(new_iter_favoritos, 0, 'FAVORITOS (SUPERIOR)')
      (1...num_columns).each do |index|
        list_store.set_value(new_iter_favoritos, index, '')
      end
      @linea_divisoria_agregada = true
    end
    new_iter_data = list_store.prepend
    values.each_with_index do |value, index|
      list_store.set_value(new_iter_data, index, value)
    end
    tree_view.selection.select_iter(new_iter_data)
  end
end

def eliminar_seleccion_interfaz(tree_view, list_store)
  selection = tree_view.selection
  iter = selection.selected
  list_store.remove(iter) if iter
end

def eliminar_seleccion_bd(tree_view, list_store)
  selection = tree_view.selection
  iter = selection.selected
  return unless iter
  dialog = Gtk::MessageDialog.new(
    parent: nil,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::QUESTION,
    buttons: Gtk::ButtonsType::YES_NO,
    message: '¿Estás seguro de que deseas eliminar la selección de la base de datos?'
  )
  dialog.title = 'Confirmación de Eliminación'
  dialog.set_position(Gtk::WindowPosition::CENTER)
  response = dialog.run
  if response == Gtk::ResponseType::YES
    id_bateria = iter[0]
    fecha_hora_eliminacion = Time.now.strftime('%Y-%m-%d %H:%M:%S')
    begin
      db = SQLite3::Database.open(NOMBRE_DB)
      db.execute('DELETE FROM tabla_de_datos WHERE ID = ?', id_bateria)
      list_store.remove(iter) if db.changes > 0
      UltimaOperacion.actualizar_ultima_operacion_realizada("Eliminación de batería: ID #{id_bateria} - #{fecha_hora_eliminacion}")
    rescue SQLite3::Exception => e
      puts "Error al eliminar la selección de la base de datos: #{e.message}"
    ensure
      db.close if db
    end
  else
    MessageHelper.show_message_window('Eliminación, cancelada')
  end
  dialog.destroy
end

def construir_menu_contextual_resultados(tree_view, list_store, status_label = nil)
  menu = Gtk::Menu.new
  selection = tree_view.selection
  item_editar = Gtk::MenuItem.new(label: 'Editar')
  item_favoritos = Gtk::MenuItem.new(label: 'Agregar a Favoritos')
  item_invertir = Gtk::MenuItem.new(label: 'Invertir Orden')
  item_eliminar_interfaz = Gtk::MenuItem.new(label: 'Eliminar (Interfaz)')
  item_eliminar_bd = Gtk::MenuItem.new(label: 'Eliminar (Base de Datos)')
  item_ver_todas = Gtk::MenuItem.new(label: 'Ver todas las baterías')

  item_editar.signal_connect('activate') do
    if (iter = selection.selected)
      create_edit_window(iter[0])
    else
      MessageHelper.show_message_window('Por favor, selecciona una batería para editar.')
    end
  end
  item_favoritos.signal_connect('activate') { agregar_a_favoritos(tree_view, list_store) }
  item_invertir.signal_connect('activate') { invertir_orden(tree_view, list_store) }
  item_eliminar_interfaz.signal_connect('activate') { eliminar_seleccion_interfaz(tree_view, list_store) }
  item_eliminar_bd.signal_connect('activate') { eliminar_seleccion_bd(tree_view, list_store) }
  item_ver_todas.signal_connect('activate') { recargar_tabla_baterias(list_store, status_label) }

  [item_editar, item_favoritos, item_invertir, item_eliminar_interfaz, item_eliminar_bd, item_ver_todas].each do |item|
    menu.append(item)
  end
  menu.show_all
  menu
end