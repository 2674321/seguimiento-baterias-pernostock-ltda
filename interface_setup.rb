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
require_relative 'battery_window'
require_relative 'statistics_window'
require_relative 'configuracion_cop_seg'
require_relative 'save_button_principal'
def create_interface(columns)
  configuracion = ConfiguracionCopiaSeguridad.new
  configuracion.start_backup_logic
  @_config_copia_seguridad = configuracion
  window = Gtk::Window.new('Ventana principal de búsqueda')
  window.set_position(Gtk::WindowPosition::CENTER)
  window.set_size_request(560, 520)
  main_box = Gtk::Box.new(:vertical, 5)
  window.add(main_box)
  header_box = Gtk::Box.new(:vertical, 2)
  header_box.set_border_width(10)
  title_label = Gtk::Label.new('Seguimiento de Baterías · PernoStock Ltda.')
  title_label.name = 'brand'
  title_label.set_line_wrap(true)
  title_label.halign = :center
  subtitle_label = Gtk::Label.new('Consulta, registro, edición, copias de seguridad y estadísticas de baterías.')
  subtitle_label.name = 'hint'
  subtitle_label.halign = :center
  header_box.pack_start(title_label, expand: false, fill: false, padding: 2)
  header_box.pack_start(subtitle_label, expand: false, fill: false, padding: 2)
  main_box.pack_start(header_box, expand: false, fill: true, padding: 2)
  search_box = Gtk::Box.new(:horizontal, 5)
  main_box.pack_start(search_box, expand: false, fill: true, padding: 5)
  entry_serie = Gtk::Entry.new
  column_combo = Gtk::ComboBoxText.new
  columns.values.each { |col_name| column_combo.append_text(col_name) }
  column_combo.active = 0
  column_combo.set_tooltip_text("Selecciona la columna para buscar\nFECHA_C = Fecha factura")
  menu_button = Gtk::Button.new
  menu_button.set_size_request(30, 30)
  create_criteria_menu(menu_button, window)
  battery_button = Gtk::Button.new
  battery_button.set_size_request(30, 30)
  battery_button.label = "Ventana Baterias"
  battery_button.set_tooltip_text('Ventana con las Baterias Registradas.')
  [Gtk::Label.new('Ingrese el valor a buscar:'), entry_serie,
   Gtk::Label.new('Seleccione la columna:'), column_combo, menu_button, battery_button].each do |element|
    search_box.pack_start(element, expand: false, fill: true, padding: 5)
  end
  battery_button.signal_connect('clicked') do
    BatteryWindow.initialize_interface
  end
  result_box = Gtk::Box.new(:vertical, 5)
  main_box.pack_start(result_box, expand: true, fill: true, padding: 5)
  result_label = Gtk::Label.new('', wrap: true, use_markup: true)
  scroll = Gtk::ScrolledWindow.new
  scroll.set_policy(:automatic, :automatic)
  scroll.add(result_label)
  buttons_box = Gtk::Box.new(:horizontal, 5)
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
  exit_button = Gtk::Button.new(label: 'Salir')
  exit_button.image = Gtk::Image.new(icon_name: "application-exit", icon_size: Gtk::IconSize::BUTTON)
  exit_button.set_tooltip_text('Cierra el programa.')
  result_box.pack_start(scroll, expand: true, fill: true, padding: 5)
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
        search_data(valor, result_label, index, columns, database)
      rescue StandardError => e
        show_message_dialog("Error", "Error en la búsqueda: #{e.message}")
      ensure
        database.close if database
      end
    end
  end
  search_buttons[1].signal_connect('clicked') do
    if result_label.text.empty?
      show_message_dialog("Advertencia", "No hay resultados para guardar.")
    else
      guardar_resultados(result_label, window)
    end
  end
  registration_button = Gtk::Button.new(label: 'Registro Bat.')
  set_button_icon(registration_button, 'list-add')
  registration_button.set_tooltip_text('Haz clic aquí para abrir la ventana de Registro de baterías.')
  registration_button.signal_connect('clicked') { create_registration_window(window) }
  buttons_box.pack_start(exit_button, expand: true, fill: true, padding: 5)
  buttons_box.pack_start(backup_button, expand: true, fill: true, padding: 5)
  buttons_box.pack_start(edit_button, expand: true, fill: true, padding: 5)
  buttons_box.pack_start(registration_button, expand: true, fill: true, padding: 5)
  registration_button.set_margin_right(50)
  search_buttons.each { |btn| buttons_box.pack_start(btn, expand: true, fill: true, padding: 5) }
  exit_button.signal_connect('clicked') do
    window.destroy
  end
  window.signal_connect('destroy') do
    @_config_copia_seguridad&.stop_backup_logic
    BackupAndExit.run_automatic_backup
    Gtk.main_quit
  end
  window.show_all
  window
end