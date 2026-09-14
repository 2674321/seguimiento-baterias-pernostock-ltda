require 'gtk3'
require 'date'
require_relative 'statistics_logic'
require_relative 'backup_exit'
require_relative 'utilities'
require_relative 'registration_window'
require_relative 'backup_window'
require_relative 'criteria_menu'
require_relative 'menu_date_window'
require_relative 'constants'
require_relative 'edit_window'
require_relative 'history_helper'
require_relative 'message_helper'
require_relative 'database_operations'
require_relative 'search_logic'
require_relative 'tabla_resultados'
require_relative 'history_window_interface'
require_relative 'statistics_window'
require_relative 'configuracion_cop_seg'
require_relative 'save_button_principal'
def create_interface(columns)
  configuracion = ConfiguracionCopiaSeguridad.new
  configuracion.start_backup_logic
  @_config_copia_seguridad = configuracion

  window = Gtk::Window.new('Ventana principal de búsqueda')
  window.set_position(Gtk::WindowPosition::CENTER)
  window.set_size_request(1200, 560)

  revealer = Gtk::Revealer.new
  revealer.transition_type = :crossfade
  revealer.transition_duration = 600
  revealer.set_margin_top(6)
  revealer.set_margin_bottom(6)
  revealer.set_margin_start(8)
  revealer.set_margin_end(8)

  main_box = Gtk::Box.new(:vertical, 6)
  revealer.add(main_box)
  window.add(revealer)

  header_box = Gtk::Box.new(:vertical, 2)
  header_box.set_border_width(10)
  title_label = Gtk::Label.new('Seguimiento de Baterías · PernoStock Ltda.')
  title_label.set_line_wrap(true)
  title_label.halign = :center
  subtitle_label = Gtk::Label.new('Consulta, registro, edición, copias de seguridad y estadísticas de baterías.')
  subtitle_label.halign = :center
  header_box.pack_start(title_label, expand: false, fill: false, padding: 2)
  header_box.pack_start(subtitle_label, expand: false, fill: false, padding: 2)
  main_box.pack_start(header_box, expand: false, fill: true, padding: 2)

  search_grid = Gtk::Grid.new
  search_grid.column_spacing = 6
  search_grid.row_spacing = 4
  entry_serie = Gtk::Entry.new
  entry_serie.hexpand = true
  column_combo = Gtk::ComboBoxText.new
  columns.values.each { |col_name| column_combo.append_text(col_name) }
  column_combo.active = 0
  column_combo.set_tooltip_text("Selecciona la columna para buscar\nFECHA_C = Fecha factura")
  menu_button = Gtk::Button.new
  menu_button.set_size_request(30, 30)
  create_criteria_menu(menu_button, window)
  columns_button = Gtk::Button.new
  columns_button.set_size_request(30, 30)
  set_button_icon(columns_button, 'view-columns-symbolic')
  columns_button.set_tooltip_text('Selecciona qué columnas mostrar en los resultados.')
  search_grid.attach(Gtk::Label.new('Buscar en:'), 0, 0, 1, 1)
  search_grid.attach(entry_serie, 1, 0, 1, 1)
  search_grid.attach(Gtk::Label.new('Columna:'), 2, 0, 1, 1)
  search_grid.attach(column_combo, 3, 0, 1, 1)
  search_grid.attach(menu_button, 4, 0, 1, 1)
  search_grid.attach(columns_button, 5, 0, 1, 1)
  main_box.pack_start(search_grid, expand: false, fill: true, padding: 4)

  result_box = Gtk::Box.new(:vertical, 2)
  main_box.pack_start(result_box, expand: true, fill: true, padding: 4)
  status_label = Gtk::Label.new('', wrap: true, use_markup: true)
  status_label.set_halign(:start)
  result_box.pack_start(status_label, expand: false, fill: false, padding: 4)
  column_db_names = columns.values
  store = Gtk::ListStore.new(*Array.new(column_db_names.size) { String })
  result_tree = Gtk::TreeView.new(store)
  result_tree.set_headers_visible(true)
  result_tree.set_rules_hint(true)
  tree_columns = []
  column_db_names.each_with_index do |col_name, i|
    tc = Gtk::TreeViewColumn.new(map_column_name(col_name), Gtk::CellRendererText.new, text: i)
    tc.set_sizing(Gtk::TreeViewColumnSizing::AUTOSIZE)
    tc.set_min_width(60)
    tc.set_resizable(true)
    result_tree.append_column(tc)
    tree_columns << tc
  end
  scroll = Gtk::ScrolledWindow.new
  scroll.set_policy(:automatic, :automatic)
  scroll.add(result_tree)
  result_box.pack_start(scroll, expand: true, fill: true, padding: 4)

  result_tree.signal_connect('button-press-event') do |_widget, event|
    if event.button == Gdk::BUTTON_SECONDARY
      construir_menu_contextual_resultados(result_tree, store, status_label).popup_at_pointer(event)
    end
  end

  recargar_tabla_baterias(store, status_label)

  columns_popover = Gtk::Popover.new(columns_button)
  columns_popover.modal = false
  columns_box_popover = Gtk::Box.new(:vertical, 2)
  columns_box_popover.set_border_width(8)
  columns_popover.add(columns_box_popover)
  columns_title = Gtk::Label.new('<b>Columnas a mostrar</b>')
  columns_title.use_markup = true
  columns_title.set_halign(:start)
  columns_box_popover.pack_start(columns_title, expand: false, fill: true, padding: 2)
  check_buttons = []
  bulk_toggle = false
  select_all_check = Gtk::CheckButton.new('Seleccionar todo')
  select_all_check.active = true
  columns_box_popover.pack_start(select_all_check, expand: false, fill: true, padding: 2)
  columns_scroll = Gtk::ScrolledWindow.new
  columns_scroll.set_policy(:never, :automatic)
  columns_scroll.set_size_request(240, 220)
  check_list_box = Gtk::Box.new(:vertical, 2)
  column_db_names.each_with_index do |col_name, i|
    check = Gtk::CheckButton.new(map_column_name(col_name))
    check.active = true
    check.signal_connect('toggled') do
      next if bulk_toggle
      if check.active?
        tree_columns[i].visible = true
      elsif check_buttons.count(&:active?) >= 1
        tree_columns[i].visible = false
      else
        check.active = true
      end
    end
    check_buttons << check
    check_list_box.pack_start(check, expand: false, fill: true, padding: 2)
  end
  columns_scroll.add(check_list_box)
  columns_box_popover.pack_start(columns_scroll, expand: true, fill: true, padding: 2)
  select_all_check.signal_connect('toggled') do
    next if bulk_toggle
    bulk_toggle = true
    if select_all_check.active?
      check_buttons.each_with_index do |check, i|
        check.active = true
        tree_columns[i].visible = true
      end
    else
      tree_columns.each { |tc| tc.visible = false }
      check_buttons.each { |check| check.active = false }
      unless check_buttons.empty?
        check_buttons.first.active = true
        tree_columns.first.visible = true
      end
    end
    bulk_toggle = false
  end
  columns_button.signal_connect('clicked') do
    columns_popover.show_all
    columns_popover.popup
  end

  buttons_box = Gtk::ButtonBox.new(:horizontal)
  buttons_box.layout = Gtk::ButtonBoxStyle::EXPAND
  buttons_box.spacing = 4
  search_buttons = ['Buscar', 'Guardar'].map { |label| Gtk::Button.new(label: label) }
  set_button_icon(search_buttons[0], 'system-search')
  set_button_icon(search_buttons[1], 'document-save')
  search_buttons[0].set_tooltip_text('Haz clic aquí para hacer consultas en la base de datos.')
  search_buttons[1].set_tooltip_text('Haz clic aquí para guardar los resultados de las consultas.')
  backup_button = Gtk::Button.new(label: 'Copia de Seguridad')
  set_button_icon(backup_button, 'document-save')
  backup_button.set_tooltip_text('La ventana de copias de seguridad.')
  backup_button.signal_connect('clicked') do
    create_backup_window_with_progress
  end
  edit_button = Gtk::Button.new(label: 'Edición')
  set_button_icon(edit_button, 'accessories-text-editor')
  edit_button.set_tooltip_text('Haz clic aquí para abrir la ventana de edición de baterías.')
  history_button = Gtk::Button.new(label: 'Historial')
  set_button_icon(history_button, 'view-list-symbolic')
  history_button.set_tooltip_text('Abrir la ventana de historial de ediciones.')
  history_button.signal_connect('clicked') { create_history_window }
  statistics_button = Gtk::Button.new(label: 'Estadísticas')
  set_button_icon(statistics_button, 'x-office-spreadsheet')
  statistics_button.set_tooltip_text('Abrir la ventana de estadísticas de operaciones.')
  statistics_button.signal_connect('clicked') { Interfaz.ventana_de_estadisticas }
  exit_button = Gtk::Button.new(label: 'Salir')
  exit_button.image = Gtk::Image.new(icon_name: "application-exit", icon_size: Gtk::IconSize::BUTTON)
  exit_button.set_tooltip_text('Cierra el programa.')
  result_box.pack_start(buttons_box, expand: false, fill: true, padding: 5)
  edit_button.signal_connect('clicked') do
    create_edit_window
  end
  entry_serie.signal_connect('activate') do
    search_buttons[0].clicked
  end
  search_buttons[0].signal_connect('clicked') do
    valor = entry_serie.text.strip
    index = column_combo.active
    if index.nil? || valor.empty?
      show_message_dialog("Error", "Por favor, seleccione una columna y escriba un valor para buscar.")
    else
      begin
        database = setup_database
        search_data(valor, store, status_label, index, columns, database)
      rescue StandardError => e
        status_label.markup = "<b>Error en la búsqueda:</b> #{e.message}"
      ensure
        database.close if database
      end
    end
  end
  search_buttons[1].signal_connect('clicked') do
    guardar_resultados(store, window)
  end
  registration_button = Gtk::Button.new(label: 'Registro Bat.')
  set_button_icon(registration_button, 'list-add')
  registration_button.set_tooltip_text('Haz clic aquí para abrir la ventana de Registro de baterías.')
  registration_button.signal_connect('clicked') { create_registration_window(window) }
  buttons_box.pack_start(exit_button, expand: true, fill: true, padding: 3)
  buttons_box.pack_start(backup_button, expand: true, fill: true, padding: 3)
  buttons_box.pack_start(edit_button, expand: true, fill: true, padding: 3)
  buttons_box.pack_start(registration_button, expand: true, fill: true, padding: 3)
  buttons_box.pack_start(history_button, expand: true, fill: true, padding: 3)
  buttons_box.pack_start(statistics_button, expand: true, fill: true, padding: 3)
  search_buttons.each { |btn| buttons_box.pack_start(btn, expand: true, fill: true, padding: 3) }
  exit_button.signal_connect('clicked') do
    window.destroy
  end
  time_box = Gtk::Box.new(:horizontal, 10)
  time_label = Gtk::Label.new('')
  time_label.halign = :end
  time_label.margin_right = 8
  time_box.pack_end(time_label, expand: false, fill: false, padding: 4)
  main_box.pack_start(time_box, expand: false, fill: false, padding: 2)
  update_time_label(time_label)
  clock_timeout_id = GLib::Timeout.add_seconds(1) { update_time_label(time_label); true }
  window.signal_connect('destroy') do
    GLib::Source.remove(clock_timeout_id) if clock_timeout_id
    @_config_copia_seguridad&.stop_backup_logic
    BackupAndExit.run_automatic_backup
    Gtk.main_quit
  end
  window
end
