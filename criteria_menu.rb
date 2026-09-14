require 'gtk3'
require_relative 'calendario'
require_relative 'user_manual'
require_relative 'menu_date_window'
require_relative 'interface_setup'
require_relative 'configuracion_cop_seg'
require_relative 'exportar_base_a_excel'

def create_criteria_menu(menu_button, window)
  menu = Gtk::Popover.new(menu_button)
  menu_box = Gtk::Box.new(:vertical, 5)
  icon = Gtk::Image.new(icon_name: 'preferences-system-symbolic', icon_size: Gtk::IconSize::BUTTON)
  menu_button.set_image(icon)
  menu_button.set_always_show_image(true)
  menu_button.set_tooltip_text('Haz clic para desplegar los criterios de búsqueda.')
  manual_button = Gtk::Button.new(label: 'Manual de uso')
  manual_button.set_tooltip_text('Haz clic para abrir el manual de uso')
  menu_box.add(manual_button)
  manual_button.signal_connect('clicked') do
    manual_window = ManualWindow.new(menu_button)
    manual_window.show
  end
  date_button = Gtk::Button.new(label: 'Rango de Fecha')
  date_button.set_tooltip_text('Haz clic para seleccionar un rango de fecha')
  menu_box.add(date_button)
  date_button.signal_connect('clicked') do
    LogicaMenuDateWindow.new.create_date_window
  end
  backup_button = Gtk::Button.new(label: 'Configuración de Copia Seg.')
  backup_button.set_tooltip_text('Haz clic para configurar las copias de seguridad')
  menu_box.add(backup_button)
  backup_button.signal_connect('clicked') do
    configuracion = ConfiguracionCopiaSeguridad.new
    configuracion.interfaz
  end
  export_button = Gtk::Button.new(label: 'Exportar base de datos a Excel')
  export_button.set_tooltip_text('Haz clic para exportar la base de datos a Excel')
  menu_box.add(export_button)

  export_button.signal_connect('clicked') do
    ExportToExcel.initialize
  end
  calendario_button = Gtk::Button.new(label: 'Calendario')
  calendario_button.set_tooltip_text('Haz clic para acceder al calendario')
  menu_box.add(calendario_button)

  calendario_button.signal_connect('clicked') do
    Calendario.show_calendar
  end
  about_button = Gtk::Button.new(label: 'Acerca de')
  about_button.set_tooltip_text('Información del sistema y autores')
  menu_box.add(about_button)
  about_button.signal_connect('clicked') do
    dialog = Gtk::AboutDialog.new
    dialog.transient_for = window
    dialog.modal = true
    dialog.program_name = 'Seguimiento de Baterías'
    dialog.version = '1.0 (histórico, 2024)'
    dialog.comments = 'Sistema de escritorio para seguimiento y gestión de baterías de PernoStock Ltda.'
    dialog.website = 'https://github.com/2674321/seguimiento-baterias-pernostock-ltda'
    dialog.website_label = 'Repositorio en GitHub'
    dialog.authors = ['Patricio Varela C. (CA2OPX)']
    dialog.license_type = Gtk::License::MIT_X11
    dialog.set_logo_icon_name('seguimiento-baterias-pernostock')
    dialog.present
  end
  menu.add(menu_box)
  menu.set_relative_to(menu_button)
  menu_button.signal_connect('clicked') do
    menu.show_all
    menu.popup
  end
end
