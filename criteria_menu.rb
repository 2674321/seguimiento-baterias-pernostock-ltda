require 'gtk3'
require_relative 'calendario'
require_relative 'user_manual'
require_relative 'menu_date_window'
require_relative 'interface_setup'
require_relative 'configuracion_cop_seg'
require_relative 'exportar_base_a_excel'
require_relative 'backup_exit'
require_relative 'message_helper'

def create_criteria_menu(menu_button, window)
  menu = Gtk::Popover.new(menu_button)
  menu_box = Gtk::Box.new(:vertical, 3)
  menu_box.set_border_width(6)
  icon = Gtk::Image.new(icon_name: 'preferences-system-symbolic', icon_size: Gtk::IconSize::BUTTON)
  menu_button.set_image(icon)
  menu_button.set_always_show_image(true)
  menu_button.set_tooltip_text('Haz clic para desplegar los criterios de búsqueda.')

  build_item = lambda do |text, icon_name, tooltip, &block|
    btn = Gtk::Button.new(label: text)
    if icon_name
      btn.image = Gtk::Image.new(icon_name: icon_name, icon_size: Gtk::IconSize::BUTTON)
      btn.always_show_image = true
    end
    btn.set_tooltip_text(tooltip)
    btn.set_halign(Gtk::Align::FILL)
    btn.signal_connect('clicked', &block) if block
    btn
  end
  add_section = lambda do |text|
    lbl = Gtk::Label.new("<b>#{text}</b>")
    lbl.use_markup = true
    lbl.set_halign(Gtk::Align::START)
    lbl.set_margin_top(6)
    lbl.set_margin_bottom(2)
    menu_box.pack_start(lbl, expand: false, fill: true, padding: 0)
    menu_box.pack_start(Gtk::Separator.new(:horizontal), expand: false, fill: true, padding: 0)
  end

  add_section.call('General')
  menu_box.pack_start(build_item.call('Manual de uso', 'help-about', 'Haz clic para abrir el manual de uso') do
    manual_window = ManualWindow.new(menu_button)
    manual_window.show
  end, expand: false, fill: true, padding: 0)
  menu_box.pack_start(build_item.call('Acerca de', 'help-about', 'Información del sistema y autores') do
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
  end, expand: false, fill: true, padding: 0)

  add_section.call('Herramientas')
  menu_box.pack_start(build_item.call('Rango de Fecha', 'appointment-new', 'Haz clic para seleccionar un rango de fecha') do
    LogicaMenuDateWindow.new.create_date_window
  end, expand: false, fill: true, padding: 0)
  menu_box.pack_start(build_item.call('Calendario', 'x-office-calendar-symbolic', 'Haz clic para acceder al calendario') do
    Calendario.show_calendar
  end, expand: false, fill: true, padding: 0)
  menu_box.pack_start(build_item.call('Importar/Exportar base de datos', 'document-send-symbolic', 'Importa (CSV/DB) o exporta (Excel) datos de la base de datos') do
    ExportToExcel.initialize
  end, expand: false, fill: true, padding: 0)

  add_section.call('Copia de seguridad')
  menu_box.pack_start(build_item.call('Configuración de Copia Seg.', 'preferences-system-symbolic', 'Haz clic para configurar las copias de seguridad') do
    configuracion = @_config_copia_seguridad || ConfiguracionCopiaSeguridad.new
    configuracion.interfaz
  end, expand: false, fill: true, padding: 0)
  menu_box.pack_start(build_item.call('Realizar copia ahora', 'document-save', 'Haz clic para crear una copia de seguridad inmediata') do
    if BackupAndExit.run_automatic_backup
      DialogHelper.show_info('Copia de seguridad', 'Copia de seguridad realizada correctamente.', parent: window)
    else
      DialogHelper.show_info('Copia de seguridad', 'No se pudo realizar la copia de seguridad.', parent: window)
    end
  end, expand: false, fill: true, padding: 0)

  menu.add(menu_box)
  menu.set_relative_to(menu_button)
  menu_button.signal_connect('clicked') do
    menu.show_all
    menu.popup
  end
end