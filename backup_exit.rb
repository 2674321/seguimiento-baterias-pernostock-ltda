require_relative 'statistics_logic'
require_relative 'constants'
require 'sqlite3'
require 'time'
require 'fileutils'
require 'yaml'
module BackupAndExit
  BACKUP_FOLDER = File.expand_path('Copias_de_seguridad/copia_de_seguridad_automatica', __dir__)
  COUNTER_FILE = File.expand_path('Ultima_copia_de_seguridad_automatica.yaml', __dir__)
  def self.create_backup_folder
    FileUtils.mkdir_p(BACKUP_FOLDER) unless Dir.exist?(BACKUP_FOLDER)
  end
  def self.backup_database(backup_filename)
    create_backup_folder
    backup_file = File.join(BACKUP_FOLDER, backup_filename)
    db = SQLite3::Database.new(NOMBRE_DB)
    begin
      db.execute('BEGIN IMMEDIATE')
      FileUtils.cp(NOMBRE_DB, backup_file)
      db.execute('ROLLBACK')
      Logica.actualizar_ultimo_respaldo_automatico(Time.now)
      save_counter_to_file(Logica.obtener_ultimo_respaldo_automatico)
    rescue StandardError => e
      show_error_dialog("Error al crear la copia de seguridad: #{e.message}")
    ensure
      db.close if db
    end
  end
  # Copia de seguridad automática NO gráfica.
  # Es la operación usada al cerrar la aplicación (evento `destroy` de la
  # ventana principal). No abre ninguna ventana GTK ni invoca un segundo
  # `Gtk.main`, por lo que es segura durante la terminación del proceso.
  def self.run_automatic_backup
    backup_filename = "Copia_de_seguridad_Automatica_#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}_base_de_datos.db"
    backup_database(backup_filename)
    true
  rescue StandardError => e
    warn "[backup] No se pudo crear la copia de seguridad automática: #{e.message}" if ENV['DEV']
    false
  end

  def self.save_counter_to_file(counter)
    File.open(COUNTER_FILE, 'w') { |file| file.write(counter.to_s) }
  end
  def self.load_counter_from_file
    return "0" unless File.exist?(COUNTER_FILE)
    stored_counter = File.read(COUNTER_FILE).strip
    return "0" if stored_counter.empty?
    Time.parse(stored_counter)
  rescue ArgumentError
    stored_counter || "0"
  end
  # Operación de backup de cierre (antes abría una ventana GTK + `Gtk.main`
  # durante la salida, lo que provocaba un segundo loop y un segfault).
  # Ahora es simplemente una operación no gráfica.
  def self.backup_exit
    run_automatic_backup
  end
end
Logica.actualizar_ultimo_respaldo_automatico(BackupAndExit.load_counter_from_file)
