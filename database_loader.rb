require 'gtk3'
require 'fileutils'
def create_backup_window_with_progress
  backup_window = Gtk::Window.new('Ventana para Copia de Seguridad')
  backup_window.set_default_size(350, 140)
  backup_window.set_position(Gtk::WindowPosition::CENTER)
  backup_window.set_border_width(10)
  save_button = Gtk::Button.new(label: 'Crear copia de seguridad')
  save_button.set_hexpand(true)
  save_button.set_tooltip_text('Realizará una copia de seguridad de la base de datos')
  close_button = Gtk::Button.new(label: 'Cerrar')
  close_button.set_hexpand(true)
  load_button = Gtk::Button.new(label: 'Cargar Base de Datos')
  load_button.set_hexpand(true)
  load_button.set_tooltip_text('Permite cargar una copia de seguridad anterior de la base de datos')
  close_button.signal_connect('clicked') do
    dialog = Gtk::Dialog.new(
      transient_for: backup_window,
      flags: Gtk::DialogFlags::MODAL,
      title: 'Confirmar cierre',
      buttons: [['Sí', Gtk::ResponseType::YES],
                ['No', Gtk::ResponseType::NO]]
    )
    dialog.child.add(Gtk::Label.new('¿Estás seguro de que quieres salir?'))
    dialog.set_position(Gtk::WindowPosition::CENTER)
    dialog.show_all
    dialog.valign = :center
    dialog.halign = :center
    response = dialog.run
    dialog.destroy
    backup_window.hide if response == Gtk::ResponseType::YES
  end
  progress_bar = Gtk::ProgressBar.new
  progress_bar.set_hexpand(true)
  progress_bar.set_show_text(true)
  save_button.signal_connect('clicked') do
    if show_confirmation_dialog(backup_window)
      backup_filename = "Copia_de_seguridad_#{Time.now.strftime('%Y-%m-%d-%H-%M-%S')}.db"
      Thread.new do
        backup_database_with_progress(backup_filename, progress_bar)
      end
    end
  end
  load_button.signal_connect('clicked') do
    absolute_path = __dir__
    dialog = Gtk::FileChooserDialog.new(
      title: 'Seleccionar archivo de base de datos',
      parent: backup_window,
      action: Gtk::FileChooserAction::OPEN,
      buttons: [
        ['Cancelar', Gtk::ResponseType::CANCEL],
        ['Abrir', Gtk::ResponseType::ACCEPT]
      ]
    )
    dialog.set_current_folder(absolute_path)
    filter_db = Gtk::FileFilter.new
    filter_db.name = 'Archivos de base de datos (*.db)'
    filter_db.add_pattern('*.db')
    dialog.add_filter(filter_db)
    if dialog.run == Gtk::ResponseType::ACCEPT
      filename = dialog.filename
      destination_file = File.join(absolute_path, 'base_de_datos.db')
      FileUtils.cp(filename, destination_file, preserve: true)
      show_info_dialog("Base de datos reemplazada con éxito.")
    end
    dialog.destroy
  end
  hbox_buttons = Gtk::Box.new(:horizontal, 5)
  hbox_buttons.margin = 10
  hbox_buttons.add(save_button)
  hbox_buttons.add(close_button)
  hbox_buttons.add(load_button)
  hbox_buttons.valign = :center
  hbox_buttons.halign = :center
  current_time_label = Gtk::Label.new("#{Time.now.strftime('%Y-%m-%d %H:%M:%S')}")
  current_time_label.set_hexpand(true)
  current_time_label.set_halign(:start)
  vbox = Gtk::Box.new(:vertical, 10)
  vbox.margin = 10
  vbox.add(progress_bar)
  vbox.add(hbox_buttons)
  vbox.add(current_time_label)
  backup_window.add(vbox)
  backup_window.show_all
  backup_window.signal_connect('delete-event') { |_widget, _event| backup_window.hide }
end
create_backup_window_with_progress if $PROGRAM_NAME == __FILE__