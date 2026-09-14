require 'gtk3'
MESSAGES = [ "Cargando datos...","Preparando información...","Inicializando sistema...","Recopilando recursos...","Optimizando rendimiento...","Esperando respuesta de la base de datos...","Procesando datos...","Verificando integridad de los datos...","Estableciendo conexión segura...","Generando informes...","Optimizando algoritmos...","Cargando configuraciones...","Analizando estadísticas...","Verificando permisos de usuario...","Comprobando compatibilidad del sistema...","Procesando solicitudes...","Buscando registros anteriores...","Sincronizando datos...","Calibrando sensores...","Analizando patrones...","Ejecutando tareas de mantenimiento..."]
def show_loading_window(duration)
  loading_window = Gtk::Window.new('Cargando...')
  loading_window.set_default_size(300, 150)
  loading_window.set_position(Gtk::WindowPosition::CENTER)
  vbox = Gtk::Box.new(Gtk::Orientation::VERTICAL, 10)
  loading_window.add(vbox)
  spinner = Gtk::Spinner.new
  vbox.pack_start(spinner, expand: true, fill: true, padding: 20)
  spinner.start
  message_label = Gtk::Label.new
  vbox.pack_start(message_label, expand: false, fill: true, padding: 10)
  spinner_timer = GLib::Timeout.add(2000) do
    if loading_window.destroyed?
      false
    else
      message_label.text = MESSAGES.sample
      true
    end
  end
  GLib::Timeout.add_seconds(duration) do
    loading_window.destroy unless loading_window.destroyed?
    GLib::Source.remove(spinner_timer)
    false
  end
  loading_window.show_all
  message_label.text = MESSAGES.first
  return loading_window
end
