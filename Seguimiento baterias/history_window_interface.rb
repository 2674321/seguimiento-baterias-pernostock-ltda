require 'gtk3'
require_relative 'constants'
require_relative 'message_helper'
require_relative 'database_operations'
require_relative 'history_data'
require_relative 'statistics_logic'
require_relative 'history_window_reset_window '
require_relative 'history_window_invert_order'
require_relative 'history_window_delete_inter'
require_relative 'history_window_delete_db'
require_relative 'history_window_add_fav'
def update_history_view(list_store, history_data)
  list_store.clear
  return if history_data.nil?
  history_data.each do |data|
    iter = list_store.append
    iter[0] = data[0].to_s #ID
    iter[1] = data[1].to_s #FECHA_HORA
    iter[2] = data[2].to_s #CAMPO_MODIFICADO
    iter[3] = data[3].to_s #VALOR_ANTERIOR
    iter[4] = data[4].to_s #VALOR_NUEVO
    iter[5] = data[5].to_s #RAZON_CAMBIO
    iter[6] = data[6].to_s #ID_BATERIA
  end
end
def create_history_window
  if @history_window_open
    MessageHelper.show_message_window("Por favor, cierre la ventana actual antes de abrir otra")
    return
  end
  history_data = HistoryData.get_data_from_database
  history_window = Gtk::Window.new
  history_window.set_title('Historial de Cambios')
  history_window.set_default_size(900, 600)
  list_store = Gtk::ListStore.new(String, String, String, String, String, String, String)
  update_history_view(list_store, history_data)
  tree_view = Gtk::TreeView.new(list_store)
  tree_view.set_headers_visible(true)
  tree_view.set_rules_hint(true)
  tree_view.set_width_request(-1)
  renderer = Gtk::CellRendererText.new
  columns = ['ID CAMBIO', 'Fecha y Hora', 'Campo Modificado', 'Valores Anteriores', 'Valores Nuevos', 'Motivo Edición', 'ID BATERIA']
  columns.each_with_index do |col_title, col|
    renderer = Gtk::CellRendererText.new
    column = Gtk::TreeViewColumn.new(col_title, renderer, text: col)
    column.set_sizing(Gtk::TreeViewColumnSizing::AUTOSIZE)
    if col_title == 'Fecha y Hora'
      column.clickable = true
      column.signal_connect('clicked') do |_widget|
        sort_order = column.sort_order || Gtk::SortType::ASCENDING
        column.sort_order = sort_order == Gtk::SortType::ASCENDING ? Gtk::SortType::DESCENDING : Gtk::SortType::ASCENDING
        tree_view.model.set_sort_column_id(col, sort_order)
      end
    end
    tree_view.append_column(column)
  end
  tree_view.signal_connect("button_press_event") do |widget, event|
    if event.button == Gdk::BUTTON_SECONDARY
      menu = Gtk::Menu.new
      item_invertir_orden_historial = Gtk::MenuItem.new(label: "Invertir Orden")
      item_invertir_orden_historial.signal_connect("activate") do
        invertir_orden(tree_view, list_store)
      end
      menu.append(item_invertir_orden_historial)
      item_restablecer_pagina_historial = Gtk::MenuItem.new(label: "Restablecer Página")
      item_restablecer_pagina_historial.signal_connect("activate") do
        restablecer_pagina_historial(list_store, tree_view)
      end
      menu.append(item_restablecer_pagina_historial)
      item_agregar_favoritos_historial = Gtk::MenuItem.new(label: "Agregar a Favoritos")
      item_agregar_favoritos_historial.signal_connect("activate") do
        agregar_a_favoritos(tree_view, list_store)
      end
      menu.append(item_agregar_favoritos_historial)
      item_eliminar_interfaz_historial = Gtk::MenuItem.new(label: "Eliminar (Interfaz)")
      item_eliminar_interfaz_historial.signal_connect("activate") do
        eliminar_seleccion_interfaz_historial(tree_view, list_store)
      end
      menu.append(item_eliminar_interfaz_historial)
      item_eliminar_bd_historial = Gtk::MenuItem.new(label: "Eliminar (Base de Datos)")
      item_eliminar_bd_historial.signal_connect("activate") do
        eliminar_seleccion_bd_historial(tree_view, list_store)
      end
      menu.append(item_eliminar_bd_historial)
      menu.show_all
      menu.popup(nil, nil, event.button, event.time)
    end
    false
  end
  title_label = Gtk::Label.new('Historial de ediciones de baterias.')
  title_label.set_margin_top(5)
  title_label.set_margin_bottom(5)
  scrolled_window = Gtk::ScrolledWindow.new
  scrolled_window.add(tree_view)
  box = Gtk::Box.new(:vertical, 5)
  box.pack_start(title_label, expand: false, fill: false, padding: 0)
  search_entry = Gtk::Entry.new
  search_entry.placeholder_text = 'Buscador de cambios específicos'
  search_entry.margin_top = 10
  search_entry.margin_bottom = 10
  search_button = Gtk::Button.new(label: 'Buscar')
  search_button.margin_top = 10
  search_button.margin_bottom = 10
  search_box = Gtk::Box.new(:horizontal, 5)
  search_box.pack_start(search_button, expand: false, fill: false, padding: 5)
  search_box.pack_start(search_entry, expand: true, fill: true, padding: 10)
  search_column_combo = Gtk::ComboBoxText.new
  columns.each_with_index { |col_title, index| search_column_combo.append_text(col_title) }
  search_column_combo.active = 0
  search_box.pack_start(search_column_combo, expand: false, fill: false, padding: 0)
  search_button.signal_connect('clicked') do |_button|
    search_text = search_entry.text
    column_index = search_column_combo.active
    HistorySearch.search_history(history_data, search_text, column_index, list_store)
    @linea_divisoria_agregada = false
  end
  box.pack_start(search_box, expand: false, fill: false, padding: 5)
  box.pack_start(scrolled_window, expand: true, fill: true, padding: 0)
  history_window.add(box)
  columns.each_with_index do |_col_title, col|
    column = tree_view.get_column(col)
    column.set_sizing(Gtk::TreeViewColumnSizing::AUTOSIZE)
  end
  history_window.signal_connect('destroy') do
    @history_window_open = false
  end
  search_entry.signal_connect('activate') do |_entry|
    search_text = search_entry.text
    column_index = search_column_combo.active
    HistorySearch.search_history(history_data, search_text, column_index, list_store)
    @linea_divisoria_agregada = false
  end
  history_window.set_position(Gtk::WindowPosition::CENTER_ALWAYS)
  @history_window_open = true
  history_window.show_all
end
