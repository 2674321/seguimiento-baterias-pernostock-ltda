require 'gtk3'
Gtk::Window.set_default_icon_name("seguimiento-baterias-pernostock")
require 'sqlite3'
require_relative 'statistics_logic'
require_relative 'constants'
require_relative 'database_operations'
require_relative 'interface_setup'
require_relative 'history_helper'
require_relative 'battery_window'
require_relative 'registration_window'
require_relative 'backup_exit'
require_relative 'show_loading_window'
def insert_initial_data_if_needed
  loading_window = show_loading_window(5)
  configurar_base_de_datos
  create_interface(Constants::TablaDeDatos::COLUMN_NAMES)
  loading_window.destroy unless loading_window.destroyed?
  Gtk.main
rescue StandardError => e
  puts e.backtrace.join("\n")
  puts "Se produjo un error al iniciar la aplicación. Detalles arriba."
end
insert_initial_data_if_needed