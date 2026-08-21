require 'gtk3'
require 'date'
require_relative 'statistics_logic'
require_relative 'backup_exit'
require_relative 'utilities'
require_relative 'registration_window'
require_relative 'backup_window'
require_relative 'criteria_menu'
require_relative 'menu_date_window'
require_relative 'date_search_window'
require_relative 'constants'
require_relative 'edit_window.rb'
require_relative 'edit_window'
require_relative 'history_helper'
require_relative 'message_helper'
require_relative 'database_operations'
require_relative 'search_logic'
require_relative 'battery_window'
require_relative 'statistics_window'
require_relative 'date_search_window'
require_relative 'search_logic'
require_relative 'configuracion_cop_seg'
require_relative 'save_button_principal'
def create_interface(columns)
  configuracion = ConfiguracionCopiaSeguridad.new
  configuracion.start_backup_logic
  window = Gtk::Window.new('Ventana principal de búsqueda')
  window.set_position(Gtk::WindowPosition::CENTER)
  window.set_size_request(400, 450)
  window.signal_connect('destroy') { Gtk.main_quit }
  main_box = Gtk::Box.new(:vertical, 5)
  window.add(main_box)
  search_box = Gtk::Box.new(:horizontal, 5)
  main_box.pack_start(search_box, expand: false, fill: true, padding: 5)
  entry_serie = Gtk::Entry.new
  column_combo = Gtk::ComboBoxText.new
  columns.values.each { |col_name| column_combo.append_text(col_name) }
  column_combo.active = 0
  column_combo.set_tooltip_text("Selecciona la columna para buscar\nFECHA_C = Fecha factura")
  menu_button = Gtk::Button.new
  menu_button.set_size_request(30, 30)
  create_criteria_menu(menu_button, main_box, window)
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
  search_buttons[0].set_tooltip_text('Haz clic aquí para hacer consultas en la base de datos.')
  search_buttons[1].set_tooltip_text('Haz clic aquí para guardar los resultados de las consultas.')
  backup_button = Gtk::Button.new(label: 'Copia de Seguridad')
  backup_button.set_tooltip_text('La ventana de copias de seguridad.')
  backup_button.signal_connect('clicked') do
    create_backup_window_with_progress
  end
  edit_button = Gtk::Button.new(label: 'Edición')
  edit_button.set_tooltip_text('Haz clic aquí para abrir la ventana de edición de baterías.')
  exit_button = Gtk::Button.new(label: 'Salir')
  exit_icon = Gtk::Image.new(icon_name: "application-exit", icon_size: Gtk::IconSize::BUTTON)
  exit_button.set_image(exit_icon)
  exit_button.set_tooltip_text('Cierra el programa.')
  exit_button.signal_connect('clicked') { Gtk.main_quit }
  result_box.pack_start(scroll, expand: true, fill: true, padding: 5)
  result_box.pack_start(buttons_box, expand: false, fill: true, padding: 5)
  edit_button.signal_connect('clicked') do
    create_edit_window
  end
  resultados_guardados = false

  entry_serie.signal_connect('activate') do
    search_buttons[0].clicked
  end
  search_buttons[0].signal_connect('clicked') do
    valor = entry_serie.text.strip
    column_text = column_combo.active_text
    index = column_combo.active

    if index.nil? || valor.empty?
      show_message_dialog("Error", "Por favor, seleccione una columna y escriba un valor para buscar.")
    else
      begin
        database = setup_database
        search_data(valor, result_label, index, columns, database)
      rescue StandardError => e
        show_message_dialog("Error", "Error en la búsqueda: #{e.message}")
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
  registration_button.set_tooltip_text('Haz clic aquí para abrir la ventana de Registro de baterías.')
  registration_button.signal_connect('clicked') { create_registration_window(window) }
  buttons_box.pack_start(exit_button, expand: true, fill: true, padding: 5)
  buttons_box.pack_start(backup_button, expand: true, fill: true, padding: 5)
  buttons_box.pack_start(edit_button, expand: true, fill: true, padding: 5)
  buttons_box.pack_start(registration_button, expand: true, fill: true, padding: 5)
  registration_button.set_margin_right(50)
  search_buttons.each { |btn| buttons_box.pack_start(btn, expand: true, fill: true, padding: 5) }
  exit_button.signal_connect('clicked') do
    Gtk.main_quit
  end
  window.signal_connect('destroy') do
    BackupAndExit.backup_exit
    Gtk.main_quit
  end
  window.show_all
  Gtk.main
end
