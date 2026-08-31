require 'gtk3'
require 'sqlite3'
require 'fileutils'
require 'date'
require_relative'constants'
require_relative'backup_window_logic'
require_relative 'statistics_logic'
BACKUP_FOLDER = 'Copias_de_seguridad'.freeze
BACKUP_PATH = File.join(File.dirname(__FILE__), BACKUP_FOLDER)
def create_backup_folder
  backup_subfolder = File.join(BACKUP_PATH, 'copias_de_seguridad_manual')
  Dir.mkdir(backup_subfolder) unless Dir.exist?(backup_subfolder)
end
def backup_database(backup_filename)
  create_backup_folder
  backup_file = File.join(BACKUP_PATH, 'copias_de_seguridad_manual', backup_filename)
  db = SQLite3::Database.new(NOMBRE_DB)
  db.execute('BEGIN IMMEDIATE')
  FileUtils.cp(NOMBRE_DB, backup_file)
  db.execute('ROLLBACK')
  UltimaOperacion.actualizar_ultima_operacion_realizada("Copia de seguridad: #{File.basename(backup_file)}")
  Logica.incrementar_contador_copias_seguridad_manuales
  puts UltimaOperacion.obtener_ultima_operacion_realizada
rescue StandardError => e
  UltimaOperacion.actualizar_ultima_operacion_realizada("Error al crear copia de seguridad manual:\n#{e.message}")
  puts UltimaOperacion.obtener_ultima_operacion_realizada
ensure
  db.close if db
end
def backup_database_with_progress(backup_filename, progress_bar)
  create_backup_folder
  backup_file = File.join(BACKUP_PATH, 'copias_de_seguridad_manual', backup_filename)
  db = SQLite3::Database.new(NOMBRE_DB)
  db.execute('BEGIN IMMEDIATE')
  10.times do |i|
    sleep(0.1)
    progress_bar.fraction = (i + 1) / 10.0
    Gtk.main_iteration while Gtk.events_pending?
  end
  FileUtils.cp(NOMBRE_DB, backup_file)
  db.execute('ROLLBACK')
  UltimaOperacion.actualizar_ultima_operacion_realizada("Copia de seguridad:\n#{File.basename(backup_file)}")
  Logica.incrementar_contador_copias_seguridad_manuales
rescue StandardError => e
  UltimaOperacion.actualizar_ultima_operacion_realizada("Error al crear copia de seguridad: #{e.message}")
  show_error_dialog(UltimaOperacion.obtener_ultima_operacion_realizada)
ensure
  db.close if db
end
