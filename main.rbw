require 'gtk3'
require 'sqlite3'
load 'reemplazo_de_datos.rb'
require_relative 'statistics_logic'
require_relative 'constants'
require_relative 'database_operations'
require_relative 'interface_setup'
require_relative 'constants'
require_relative 'history_helper'
require_relative 'battery_window'
require_relative 'registration_window'
require_relative 'backup_exit'
require_relative 'show_loading_window'
data_to_insert = []
def insert_initial_data_if_needed(data)
  begin
    loading_window = show_loading_window(5)
    db = SQLite3::Database.new(NOMBRE_DB)
    db_created = false
    unless db_created
      configurar_base_de_datos
      db_created = true
    end
    unless check_initial_data_inserted(db, data)
      insertar_datos(db, data)
    end
    loading_window.signal_connect('destroy') do |_|
      create_interface(Constants::TablaDeDatos::COLUMN_NAMES)
    end
    Gtk.main
  rescue StandardError => e
    puts e.backtrace
    gets
  end
end
def check_and_create_indicator_table(db)
  indicator_table_exists = db.execute("SELECT name FROM sqlite_master WHERE type='table' AND name='#{INDICATOR_TABLE_NAME}';").any?
  unless indicator_table_exists
    db.execute("CREATE TABLE #{INDICATOR_TABLE_NAME} (inserted INTEGER);")
    db.execute("INSERT INTO #{INDICATOR_TABLE_NAME} (inserted) VALUES (0);")
  else
  end
end
insert_initial_data_if_needed(data_to_insert)
