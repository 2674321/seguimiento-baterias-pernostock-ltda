require 'gtk3'
require 'fileutils'
class ConfiguracionCopiaSeguridad
  CONFIG_FILE = 'configuracion.yaml'
  def initialize
    @intervalo_tiempo = 30
    @activar_al_inicio = true
    load_configuration
  end
  def load_configuration
    begin
      if File.exist?(CONFIG_FILE)
        config_data = YAML.load_file(CONFIG_FILE)
        @intervalo_tiempo = config_data['intervalo_tiempo']
        @activar_al_inicio = config_data['activar_al_inicio']
        print_configuration
      else
        #puts "El archivo de configuración YAML no existe."
      end
    rescue => e
      #puts "Error al cargar la configuración desde el archivo YAML: #{e.message}"
    end
  end
  def save_configuration
    config_data = {
      'intervalo_tiempo' => @intervalo_tiempo,
      'activar_al_inicio' => @activar_al_inicio
    }
    File.open(CONFIG_FILE, 'w') { |file| file.write(config_data.to_yaml) }
  end
  def start_configuration_logic
    logica_configuracion_automatica
    logica_configuracion_automatica_salida
  end
  def start_backup_logic
    logica_configuracion_automatica if @activar_al_inicio
  end
  def interfaz
    window = Gtk::Window.new("Configuración de Copias de Seguridad")
    window.set_default_size(400, 200)
    window.set_position(Gtk::WindowPosition::CENTER)
    window.signal_connect("destroy") { Gtk.main_quit }
    vbox = Gtk::Box.new(:vertical, 5)
    title_label = Gtk::Label.new("Configuración de Copias de Seguridad")
    vbox.pack_start(title_label, expand: false, fill: true, padding: 10)
    add_automatic_backup_section(vbox)
    window.add(vbox)
    window.show_all
    realizar_copia_de_seguridad if @activar_al_inicio
    Gtk.main
  end
  def realizar_copia_de_seguridad
    backup_directory = File.join(Dir.pwd, 'Copias_de_seguridad', 'Copias_de_seguridad_temporizadas')
    FileUtils.mkdir_p(backup_directory) unless File.directory?(backup_directory)
    backup_file = File.join(backup_directory, "Copia_temporizada_#{Time.now.strftime('%Y-%m-%d_%H-%M-%S')}.db")
    FileUtils.cp('base_de_datos.db', backup_file)
  end
  def logica_configuracion_automatica_salida
  end
  private
  def logica_configuracion_automatica
    Thread.new do
      loop do
        realizar_copia_de_seguridad
        sleep(@intervalo_tiempo * 60)
      end
    end
  end
  def add_automatic_backup_section(vbox)
    menu1_label = Gtk::Label.new("Copia de seguridad Automática-Temporizada")
    vbox.pack_start(menu1_label, expand: false, fill: true, padding: 5)
    combo1 = Gtk::ComboBoxText.new
    combo1.append_text("Cada 5 minutos")
    combo1.append_text("Cada 10 minutos")
    combo1.append_text("Cada 30 minutos (recomendado)")
    combo1.append_text("Cada 50 minutos")
    combo1.append_text("Cada 1 hora")
    combo1.append_text("Cada 2 horas")
    set_active_index(combo1)
    combo1.signal_connect('changed') do |widget|
      @intervalo_tiempo = parse_intervalo_tiempo(widget.active_text)
      save_configuration
    end
    vbox.pack_start(combo1, expand: false, fill: true, padding: 5)
  end
  def set_active_index(combo)
    case @intervalo_tiempo
    when 5
      combo.active = 0
    when 10
      combo.active = 1
    when 30
      combo.active = 2
    when 50
      combo.active = 3
    when 60
      combo.active = 4
    when 120
      combo.active = 5
    else
      combo.active = 2
    end
  end
  def parse_intervalo_tiempo(texto)
    intervalo_tiempo = case texto
                        when "Cada 5 minutos"
                          5
                        when "Cada 10 minutos"
                          10
                        when "Cada 30 minutos (recomendado)"
                          30
                        when "Cada 50 minutos"
                          50
                        when "Cada 1 hora"
                          60
                        when "Cada 2 horas"
                          120
                        else
                          30
                        end
                        #puts "intervalo de tiempo cambiado a: #{intervalo_tiempo}"
    intervalo_tiempo
  end
  def print_configuration
     #puts "Intervalo de tiempo: #{@intervalo_tiempo} minutos"
     #puts "Activar al inicio: #{@activar_al_inicio ? 'Sí' : 'No'}"
   end
end
