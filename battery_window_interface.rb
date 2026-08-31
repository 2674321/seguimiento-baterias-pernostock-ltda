require 'date'
require 'gtk3'
require 'sqlite3'
require_relative 'edit_window_interface'
require_relative 'constants'
require_relative 'battery_window_logic'
require_relative 'database_operations'
require_relative 'message_helper'
require_relative 'history_window_interface'
require_relative 'interface_setup'
require_relative 'battery_window_search_logic'
require_relative 'statistics_window'
require_relative 'statistics_logic'
require_relative 'battery_window_delete_db'
require_relative 'battery_window_delete_interface'
require_relative 'battery_window_reset_window'
require_relative 'battery_window_add_fav'
def create_battery_window
  if @battery_window_open
    MessageHelper.show_message_window("Por favor, cierre la ventana actual antes de abrir otra")
    return
  end
  battery_data = obtener_datos_baterias
  if battery_data.nil?
    MessageHelper.show_message_window("Error al obtener datos de la base de datos.")
    return
  end
  battery_window = Gtk::Window.new('Ventana de Baterias')
  battery_window.set_default_size(800, 550)
  list_store = Gtk::ListStore.new(
    String, String, String, String, String, String, String,
    String, String, String, String, String, String, String, String
  )
  update_battery_view(list_store, battery_data)
  tree_view = Gtk::TreeView.new(list_store)
  tree_view.set_headers_visible(true)
  tree_view.set_rules_hint(true)
  tree_view.set_width_request(-1)
  tree_view.set_rules_hint(true)
  renderer = Gtk::CellRendererText.new
  selection = tree_view.selection
  columns = [' ID BATERIA ', ' MODELO ', ' SERIE ', ' RECEPCION ', ' FACTURA ', ' FECHA FACTURA ', ' N.C ', ' FECHA N.C ', ' MOTIVO DEV.', ' CLIENTE ', ' VENDEDOR ', ' RECARGA ', ' FECHA ENVIO ', ' DESTINO ', ' COMENTARIOS ']
  columns.each_with_index do |col_title, col|
    column = Gtk::TreeViewColumn.new(col_title, renderer, text: col)
    column.set_sizing(Gtk::TreeViewColumnSizing::AUTOSIZE)
    tree_view.append_column(column)
    column.signal_connect('clicked') do |_widget|
    end
  end
  tree_view.signal_connect('row-activated') do |_widget, path, _column|
  end
  tree_view.signal_connect('button-press-event') do |_widget, event|
    if event.button == Gdk::BUTTON_SECONDARY
      menu = Gtk::Menu.new
      item_invertir_orden = Gtk::MenuItem.new(:label => "Invertir Orden")
      item_restablecer_pagina = Gtk::MenuItem.new(:label => "Restablecer Página")
      item_agregar_favoritos = Gtk::MenuItem.new(:label => "Agregar a Favoritos")
      item_editar = Gtk::MenuItem.new(:label => "Editar")
      item_eliminar_interfaz = Gtk::MenuItem.new(:label => "Eliminar (Interfaz)")
      item_eliminar_bd = Gtk::MenuItem.new(:label => "Eliminar (Base de Datos)")

      item_invertir_orden.signal_connect("activate") do
        invertir_orden(tree_view, list_store)
      end
      item_agregar_favoritos.signal_connect("activate") do
        agregar_a_favoritos(tree_view, list_store)
      end
      item_restablecer_pagina.signal_connect("activate") do
        restablecer_pagina(tree_view, list_store)
      end
      item_editar.signal_connect("activate") do
        selected_row = selection.selected
        if selected_row
          id = selected_row[0]
          editar_baterias(id)
        else
          MessageHelper.show_message_window("Por favor, selecciona una batería para editar.")
        end
      end
      item_eliminar_interfaz.signal_connect("activate") do
        eliminar_seleccion_interfaz(tree_view, list_store)
      end
      item_eliminar_bd.signal_connect("activate") do
        eliminar_seleccion_bd(tree_view, list_store)
      end
      menu.append(item_invertir_orden)
      menu.append(item_restablecer_pagina)
      menu.append(item_agregar_favoritos)
      menu.append(item_editar)
      menu.append(item_eliminar_interfaz)
      menu.append(item_eliminar_bd)
      menu.show_all
      menu.popup(nil, nil, event.button, event.time)
    end
  end
  scrolled_window = Gtk::ScrolledWindow.new
  scrolled_window.add(tree_view)
  box = Gtk::Box.new(:vertical, 5)
  time_label = Gtk::Label.new
  time_label.halign = :end
  time_label.valign = :start
  time_label.margin_right = 10
  def update_time_label(label)
    return unless label && !label.destroyed?
    begin
      current_time = Time.now
      formatted_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
      label.text = "#{formatted_time}"
    rescue StandardError => e
      puts "Error updating time label: #{e.message}"
      puts e.backtrace.join("\n")
    end
  end
  def on_destroy(window)
    @battery_window_open = false
    GLib::Source.remove(@timeout_id) if @timeout_id
  end
  time_box = Gtk::Box.new(:horizontal, 10)
  time_box.pack_end(time_label, expand: false, fill: false, padding: 5)
  box.pack_end(time_box, expand: false, fill: false, padding: 5)
  search_box = Gtk::Box.new(:horizontal, 5)
  search_column_combo = Gtk::ComboBoxText.new
  columns.each_with_index { |col_title, index| search_column_combo.append_text(col_title) }
  search_column_combo.active = 0
  search_entry = Gtk::Entry.new
  search_entry.placeholder_text = 'Buscador de cambios general.'
  search_entry.margin_top = 10
  search_entry.margin_bottom = 10
  search_entry.set_width_chars(130)
  search_button = Gtk::Button.new(label: 'Buscar')
  search_button.margin_top = 10
  search_button.margin_bottom = 10
  search_button.set_tooltip_text('Buscar')
  open_window_button = Gtk::Button.new(label: 'Estadísticas')
  open_window_button.margin_top = 10
  open_window_button.margin_bottom = 10
  open_window_button.set_tooltip_text('Abrir la ventana de estadísticas de operaciones')
  history_button = Gtk::Button.new(label: 'Historial')
  history_button.margin_top = 10
  history_button.margin_bottom = 10
  history_button.set_tooltip_text('Abrir la ventana de historial de Ediciónes')
  edit_button = Gtk::Button.new(label: 'Edición')
  edit_button.margin_top = 10
  edit_button.margin_bottom = 10
  edit_button.set_tooltip_text('Botón de edición')
  [search_button, open_window_button, history_button, edit_button].each do |button|
    button.set_size_request(120, -1)
  end
  edit_button.signal_connect('clicked') do |_button|
    create_edit_window
  end
  box.pack_start(scrolled_window, expand: true, fill: true, padding: 0)
  search_box.pack_start(search_column_combo, expand: false, fill: false, padding: 0)
  search_box.pack_start(search_button, expand: false, fill: false, padding: 5)
  search_box.pack_start(search_entry, expand: false, fill: false, padding: 10)
  search_box.pack_start(edit_button, expand: false, fill: false, padding: 5)
  search_box.pack_start(history_button, expand: false, fill: false, padding: 5)
  search_box.pack_start(open_window_button, expand: false, fill: false, padding: 5)
  search_button.signal_connect('clicked') do |_button|
    search_text = search_entry.text
    column_index = search_column_combo.active
    buscar_en_battery_window(column_index, search_text, battery_data, list_store)
    @linea_divisoria_agregada = false
  end
  open_window_button.signal_connect('clicked') do |_button|
    Interfaz.ventana_de_estadisticas
  end
  box.pack_end(search_box, expand: false, fill: false, padding: 0)
  battery_window.add(box)
  columns.each_with_index do |_col_title, col|
    column = tree_view.get_column(col)
    column.set_sizing(Gtk::TreeViewColumnSizing::AUTOSIZE)
  end
  battery_window.signal_connect('destroy') do
    on_destroy(battery_window)
  end
  history_button.signal_connect('clicked') do |_button|
    create_history_window
  end
  search_entry.signal_connect('activate') do |_entry|
    search_text = search_entry.text
    column_index = search_column_combo.active
    buscar_en_battery_window(column_index, search_text, battery_data, list_store)
    @linea_divisoria_agregada = false
  end
  update_time_label(time_label)
  @timeout_id = GLib::Timeout.add_seconds(1) { update_time_label(time_label); true }
  battery_window.set_position(Gtk::WindowPosition::CENTER_ALWAYS)
  @battery_window_open = true
  battery_window.show_all
end
def editar_baterias(id)
  create_edit_window(id)
end
