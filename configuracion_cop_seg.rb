require 'gtk3'
require 'yaml'
require 'fileutils'
require 'time'
require_relative 'constants'
require_relative 'statistics_logic'
require_relative 'backup_exit'
require_relative 'dialog_helper'
class ConfiguracionCopiaSeguridad
  CONFIG_FILE = 'configuracion.yaml'
  DEFAULT_INTERVALO = 30
  DEFAULT_ACTIVAR_AL_INICIO = true
  INTERVALOS = {
    'Cada 5 minutos' => 5,
    'Cada 10 minutos' => 10,
    'Cada 30 minutos (recomendado)' => 30,
    'Cada 50 minutos' => 50,
    'Cada 1 hora' => 60,
    'Cada 2 horas' => 120
  }.freeze

  def initialize
    @intervalo_tiempo = DEFAULT_INTERVALO
    @activar_al_inicio = DEFAULT_ACTIVAR_AL_INICIO
    @backup_thread = nil
    @stop_backup = false
    load_configuration
  end
  def load_configuration
    return unless File.exist?(CONFIG_FILE)
    config_data = YAML.load_file(CONFIG_FILE)
    @intervalo_tiempo = config_data['intervalo_tiempo'] if config_data['intervalo_tiempo'].is_a?(Integer) && INTERVALOS.value?(config_data['intervalo_tiempo'])
    @activar_al_inicio = !!config_data['activar_al_inicio'] unless config_data['activar_al_inicio'].nil?
  rescue StandardError => e
    puts "Error al cargar la configuración: #{e.message}"
  end
  def save_configuration
    config_data = {
      'intervalo_tiempo' => @intervalo_tiempo,
      'activar_al_inicio' => @activar_al_inicio
    }
    File.open(CONFIG_FILE, 'w') { |file| file.write(config_data.to_yaml) }
  end
  def start_backup_logic
    return if @backup_thread && @backup_thread.alive?
    logica_configuracion_automatica if @activar_al_inicio
  end
  def stop_backup_logic
    @stop_backup = true
    return unless @backup_thread
    @backup_thread.join(1) if @backup_thread.alive?
  end
  def interfaz
    window = Gtk::Window.new("Configuración de Copias de Seguridad")
    window.set_default_size(460, 340)
    window.set_position(Gtk::WindowPosition::CENTER)
    vbox = Gtk::Box.new(:vertical, 8)
    vbox.set_border_width(12)
    title_label = Gtk::Label.new('Configuración de Copias de Seguridad')
    title_label.set_halign(:center)
    vbox.pack_start(title_label, expand: false, fill: true, padding: 6)

    frame = Gtk::Frame.new(' Copia automática temporizada ')
    grid = Gtk::Grid.new
    grid.column_spacing = 8
    grid.row_spacing = 8
    grid.set_margin_top(12)
    grid.set_margin_bottom(12)
    grid.set_margin_start(12)
    grid.set_margin_end(12)
    frame.add(grid)
    vbox.pack_start(frame, expand: false, fill: true, padding: 0)

    interval_label = Gtk::Label.new('Intervalo entre copias:')
    interval_label.set_halign(:start)
    grid.attach(interval_label, 0, 0, 1, 1)
    combo1 = Gtk::ComboBoxText.new
    INTERVALOS.each_key { |label| combo1.append_text(label) }
    set_active_index(combo1)
    combo1.signal_connect('changed') do |widget|
      @intervalo_tiempo = parse_intervalo_tiempo(widget.active_text)
      save_configuration
    end
    combo1.hexpand = true
    grid.attach(combo1, 1, 0, 1, 1)

    activar_check = Gtk::CheckButton.new('Activar copia automática al iniciar la aplicación')
    activar_check.active = @activar_al_inicio
    activar_check.signal_connect('toggled') do
      @activar_al_inicio = activar_check.active?
      save_configuration
      if @activar_al_inicio
        start_backup_logic
      else
        stop_backup_logic
      end
    end
    grid.attach(activar_check, 0, 1, 2, 1)

    last_backup = Logica.obtener_ultimo_respaldo_automatico
    last_text = if last_backup.is_a?(Time)
                  last_backup.strftime('%d/%m/%Y %H:%M:%S')
                else
                  'No se ha realizado ninguna copia automática aún.'
                end
    last_label = Gtk::Label.new("Última copia automática: #{last_text}")
    last_label.set_halign(:start)
    last_label.set_line_wrap(true)
    grid.attach(last_label, 0, 2, 2, 1)

    buttons_hbox = Gtk::Box.new(:horizontal, 6)
    backup_now_button = Gtk::Button.new(label: 'Realizar copia ahora')
    backup_now_button.set_size_request(180, 32)
    backup_now_button.signal_connect('clicked') do
      ok = BackupAndExit.run_automatic_backup
      if ok
        DialogHelper.show_info('Copia de seguridad', 'Copia de seguridad realizada correctamente.', parent: window)
        last_label.text = "Última copia automática: #{Time.now.strftime('%d/%m/%Y %H:%M:%S')}"
      else
        DialogHelper.show_info('Copia de seguridad', 'No se pudo realizar la copia de seguridad.', parent: window)
      end
    end
    buttons_hbox.pack_start(backup_now_button, expand: true, fill: true, padding: 0)
    close_button = Gtk::Button.new(label: 'Cerrar')
    close_button.set_size_request(120, 32)
    close_button.signal_connect('clicked') { window.destroy }
    buttons_hbox.pack_start(close_button, expand: true, fill: true, padding: 0)
    vbox.pack_start(buttons_hbox, expand: false, fill: true, padding: 6)

    window.add(vbox)
    window.show_all
    window
  end
  def realizar_copia_de_seguridad
    unless File.exist?(NOMBRE_DB)
      puts "No se ha encontrado #{NOMBRE_DB}; se omite la copia temporizada."
      return
    end
    backup_directory = File.join(Dir.pwd, 'Copias_de_seguridad', 'Copias_de_seguridad_temporizadas')
    FileUtils.mkdir_p(backup_directory) unless File.directory?(backup_directory)
    backup_file = File.join(backup_directory, "Copia_temporizada_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.db")
    FileUtils.cp(NOMBRE_DB, backup_file)
  rescue StandardError => e
    puts "Error al crear copia temporizada: #{e.message}"
  end
  private
  def logica_configuracion_automatica
    @stop_backup = false
    @backup_thread = Thread.new do
      loop do
        break if @stop_backup
        realizar_copia_de_seguridad
        break if @stop_backup
        sleep(@intervalo_tiempo * 60)
      end
    end
  end
  def set_active_index(combo)
    labels = INTERVALOS.keys
    index = INTERVALOS.value?(@intervalo_tiempo) ? labels.index { |label| INTERVALOS[label] == @intervalo_tiempo } : 2
    combo.active = index || 2
  end
  def parse_intervalo_tiempo(texto)
    INTERVALOS.fetch(texto, DEFAULT_INTERVALO)
  end
end