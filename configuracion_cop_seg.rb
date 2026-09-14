require 'gtk3'
require 'yaml'
require 'fileutils'
require_relative 'constants'
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
    logica_configuracion_automatica if @activar_al_inicio
  end
  def stop_backup_logic
    @stop_backup = true
    return unless @backup_thread
    @backup_thread.join(1) if @backup_thread.alive?
  end
  def interfaz
    window = Gtk::Window.new("Configuración de Copias de Seguridad")
    window.set_default_size(400, 200)
    window.set_position(Gtk::WindowPosition::CENTER)
    vbox = Gtk::Box.new(:vertical, 5)
    title_label = Gtk::Label.new("Configuración de Copias de Seguridad")
    vbox.pack_start(title_label, expand: false, fill: true, padding: 10)
    add_automatic_backup_section(vbox)
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
  def add_automatic_backup_section(vbox)
    menu1_label = Gtk::Label.new("Copia de seguridad Automática-Temporizada")
    vbox.pack_start(menu1_label, expand: false, fill: true, padding: 5)
    combo1 = Gtk::ComboBoxText.new
    INTERVALOS.each_key { |label| combo1.append_text(label) }
    set_active_index(combo1)
    combo1.signal_connect('changed') do |widget|
      @intervalo_tiempo = parse_intervalo_tiempo(widget.active_text)
      save_configuration
    end
    vbox.pack_start(combo1, expand: false, fill: true, padding: 5)
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