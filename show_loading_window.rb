require 'gtk3'
require_relative 'app_theme'
MESSAGES = [ "Cargando datos...","Preparando información...","Inicializando sistema...","Recopilando recursos...","Optimizando rendimiento...","Esperando respuesta de la base de datos...","Procesando datos...","Verificando integridad de los datos...","Estableciendo conexión segura...","Generando informes...","Optimizando algoritmos...","Cargando configuraciones...","Analizando estadísticas...","Verificando permisos de usuario...","Comprobando compatibilidad del sistema...","Procesando solicitudes...","Buscando registros anteriores...","Sincronizando datos...","Calibrando sensores...","Analizando patrones...","Ejecutando tareas de mantenimiento..."]
def show_loading_window(duration)
  AppTheme.install
  loading_window = Gtk::Window.new('Cargando...')
  loading_window.set_default_size(420, 240)
  loading_window.set_position(Gtk::WindowPosition::CENTER)
  loading_window.style_context.add_class('splash')
  vbox = Gtk::Box.new(Gtk::Orientation::VERTICAL, 8)
  vbox.set_border_width(24)
  loading_window.add(vbox)

  brand_label = Gtk::Label.new('Seguimiento de Baterías · PernoStock Ltda.')
  brand_label.name = 'brand'
  brand_label.set_line_wrap(true)
  brand_label.halign = :center
  vbox.pack_start(brand_label, expand: false, fill: false, padding: 4)

  subtitle_label = Gtk::Label.new('Iniciando la aplicación…')
  subtitle_label.name = 'hint'
  subtitle_label.halign = :center
  vbox.pack_start(subtitle_label, expand: false, fill: false, padding: 2)

  icon = Gtk::Image.new(icon_name: 'seguimiento-baterias-pernostock', icon_size: Gtk::IconSize::DIALOG)
  vbox.pack_start(icon, expand: true, fill: false, padding: 10)

  spinner = Gtk::Spinner.new
  spinner.set_size_request(48, 48)
  vbox.pack_start(spinner, expand: false, fill: false, padding: 6)
  spinner.start

  message_label = Gtk::Label.new(MESSAGES.first)
  message_label.halign = :center
  vbox.pack_start(message_label, expand: false, fill: false, padding: 2)

  progress_bar = Gtk::ProgressBar.new
  progress_bar.set_size_request(-1, 14)
  vbox.pack_start(progress_bar, expand: false, fill: true, padding: 8)

  spinner_timer = GLib::Timeout.add(1500) do
    if loading_window.destroyed?
      false
    else
      message_label.text = MESSAGES.sample
      true
    end
  end
  progress_timer = GLib::Timeout.add(50) do
    if loading_window.destroyed?
      false
    else
      progress_bar.fraction += 0.01
      true
    end
  end
  GLib::Timeout.add_seconds(duration) do
    unless loading_window.destroyed?
      progress_bar.fraction = 1.0
      loading_window.destroy
      begin
        GLib::Source.remove(spinner_timer)
        GLib::Source.remove(progress_timer)
      rescue StandardError
      end
    end
    false
  end
  loading_window.show_all
  loading_window
end