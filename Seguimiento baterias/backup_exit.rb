require_relative 'statistics_logic'
require_relative 'constants'
require 'gtk3'
require 'sqlite3'
require 'fileutils'
require 'yaml'
module BackupAndExit
  BACKUP_FOLDER = File.expand_path('Copias_de_seguridad/copia_de_seguridad_automatica', __dir__)
  COUNTER_FILE = File.expand_path('Ultima_copia_de_seguridad_automatica.yaml', __dir__)
  def self.create_backup_folder
    FileUtils.mkdir_p(BACKUP_FOLDER) unless Dir.exist?(BACKUP_FOLDER)
  end
  def self.at_exit_backup
    at_exit do
      backup_exit
    end
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
  def self.save_counter_to_file(counter)
    File.open(COUNTER_FILE, 'w') { |file| file.write(counter.to_s) }
  end
  def self.load_counter_from_file
    stored_counter = File.read(COUNTER_FILE) if File.exist?(COUNTER_FILE)
    stored_counter || "0"
  end
  def self.backup_database_with_progress(backup_filename, progress_bar)
    create_backup_folder
    backup_file = File.join(BACKUP_FOLDER, backup_filename)
    db = SQLite3::Database.new(NOMBRE_DB)
    begin
      db.execute('BEGIN IMMEDIATE')
      10.times do |i|
        sleep(0.1)
        progress_bar.fraction = (i + 1) / 10.0
        Gtk.main_iteration while Gtk.events_pending?
      end
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
  def self.backup_exit
    progress_window = Gtk::Window.new
    progress_window.title = 'Copia de Seguridad en Progreso'
    progress_window.set_default_size(400, 150)
    progress_window.border_width = 10
    progress_window.set_position(Gtk::WindowPosition::CENTER)
    vbox = Gtk::Box.new(:vertical, 5)
    vbox.homogeneous = true
    progress_window.add(vbox)
    title_label = Gtk::Label.new('Realizando Copia de Seguridad...')
    title_label.halign = :center
    vbox.pack_start(title_label, expand: false, fill: false, padding: 10)
    progress_bar = Gtk::ProgressBar.new
    progress_bar.fraction = 0.0
    vbox.pack_start(progress_bar, expand: false, fill: false, padding: 10)
    progress_window.show_all
    backup_filename = "Copia_de_seguridad_Automatica_#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}_base_de_datos.db"
    Thread.new do
      backup_database_with_progress(backup_filename, progress_bar)
      GLib::Timeout.add(1000) do
        progress_window.destroy
        Gtk.main_quit
        GLib::Source::REMOVE
      end
    end
    Gtk.main
  end
end
Logica.actualizar_ultimo_respaldo_automatico(BackupAndExit.load_counter_from_file)
at_exit { BackupAndExit.backup_exit}
