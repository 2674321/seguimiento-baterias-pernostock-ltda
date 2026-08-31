require 'gtk3'
MESSAGES = [ "Cargando datos...","Preparando información...","Inicializando sistema...","Recopilando recursos...","Optimizando rendimiento...","Esperando respuesta de la base de datos...","Procesando datos...","Verificando integridad de los datos...","Estableciendo conexión segura...","Generando informes...","Optimizando algoritmos...","Cargando configuraciones...","Analizando estadísticas...","Verificando permisos de usuario...","Comprobando compatibilidad del sistema...","Procesando solicitudes...","Buscando registros anteriores...","Sincronizando datos...","Calibrando sensores...","Analizando patrones...","Ejecutando tareas de mantenimiento..."]
def show_loading_window(duration)
  loading_window = Gtk::Window.new
  loading_window.title = 'Cargando...'
  loading_window.set_default_size(300, 150)
  loading_window.set_window_position(Gtk::WindowPosition::CENTER)
  vbox = Gtk::Box.new(Gtk::Orientation::VERTICAL, 10)
  loading_window.add(vbox)
  spinner = Gtk::Spinner.new
  vbox.pack_start(spinner, expand: true, fill: true, padding: 20)
  spinner.start
  progressbar = Gtk::ProgressBar.new
  vbox.pack_start(progressbar, expand: false, fill: true, padding: 10)
  message_label = Gtk::Label.new
  vbox.pack_start(message_label, expand: false, fill: true, padding: 10)
  loading_effect = 0.0
  GLib::Timeout.add(50) do
    loading_effect += 0.01
    loading_effect = 0.0 if loading_effect >= 1.0
    progressbar.fraction = loading_effect
    true
  end
  message_index = 0
  GLib::Timeout.add(2000) do
    random_message = MESSAGES.sample
    message_label.text = random_message
    true
  end
  GLib::Timeout.add_seconds(duration) do
    loading_window.destroy
    false
  end
  loading_window.signal_connect("destroy") do
    exit
  end
  loading_window.show_all
  message_label.text = MESSAGES.first
  return loading_window
end
