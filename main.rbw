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
  loading_window = show_loading_window
  started_at = Process.clock_gettime(Process::CLOCK_MONOTONIC)
  min_display_ms = 2500
  GLib::Timeout.add(400) do
    begin
      configurar_base_de_datos
      create_interface(Constants::TablaDeDatos::COLUMN_NAMES)
    rescue StandardError => e
      puts e.backtrace.join("\n")
      puts "Se produjo un error al iniciar la aplicación. Detalles arriba."
    ensure
      elapsed_ms = (Process.clock_gettime(Process::CLOCK_MONOTONIC) - started_at) * 1000
      remaining_ms = (min_display_ms - elapsed_ms).clamp(100, min_display_ms)
      GLib::Timeout.add(remaining_ms.to_i) do
        unless loading_window.destroyed?
          loading_window.destroy
        end
        false
      end
    end
    false
  end
  Gtk.main
rescue StandardError => e
  puts e.backtrace.join("\n")
  puts "Se produjo un error al iniciar la aplicación. Detalles arriba."
end
insert_initial_data_if_needed