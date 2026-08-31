def validate_data(data)
  return false if data.nil? || data.empty?
  data.all? { |value| value.is_a?(String) && !value.strip.empty? }
end
def save_results(results)
  dialog = setup_file_chooser_dialog
  if dialog.run == :accept
    file_path = obtain_file_path(dialog)
    save_to_file(file_path, results)
    dialog.destroy
    show_message('Los resultados se guardaron exitosamente.')
  else
    dialog.destroy
  end
end
def show_message_dialog(title, message)
  dialog = Gtk::MessageDialog.new(
    parent: nil,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::INFO,
    buttons: Gtk::ButtonsType::OK,
    message: nil
  )
  dialog.title = title
  dialog.set_markup("<span size='medium' foreground='black'>#{message}</span>")
  dialog.window_position = Gtk::WindowPosition::CENTER
  dialog.run
  dialog.destroy
end
def setup_file_chooser_dialog
  dialog = Gtk::FileChooserDialog.new(
    title: 'Guardar resultados',
    action: :save,
    buttons: [
      [Gtk::Stock::CANCEL, :cancel],
      [Gtk::Stock::SAVE, :accept]
    ])
  add_filters(dialog)
  dialog.set_default_response(:accept)
  dialog
end
def add_filters(dialog)
  filter_text = Gtk::FileFilter.new
  filter_text.name = 'Archivos de texto'
  filter_text.add_pattern('*.txt')
  dialog.add_filter(filter_text)
  filter_csv = Gtk::FileFilter.new
  filter_csv.name = 'Archivos CSV'
  filter_csv.add_pattern('*.csv')
  dialog.add_filter(filter_csv)
  filter_docx = Gtk::FileFilter.new
  filter_docx.name = 'Archivos DOCX'
  filter_docx.add_pattern('*.docx')
  dialog.add_filter(filter_docx)
  filter_json = Gtk::FileFilter.new
  filter_json.name = 'Archivos JSON'
  filter_json.add_pattern('*.json')
  dialog.add_filter(filter_json)
end
def obtain_file_path(dialog)
  file_path = dialog.filename
  filter_selected = dialog.filter
  extension = case filter_selected.name.downcase
    when 'archivos de texto'
      'txt'
    else
      filter_selected.name.split.last.downcase
    end
  file_path += ".#{extension}" if extension != File.extname(file_path).delete('.')
  file_path
end
def save_to_file(file_path, results)
  File.write(file_path, "#{results}")
  file_name = File.basename(file_path)
  program_directory = __dir__
  default_folder_path = File.join(program_directory, "archivos_guardados")
  Dir.mkdir(default_folder_path) unless Dir.exist?(default_folder_path)
  extension = File.extname(file_path).delete('.')
  case extension.downcase
  when 'csv', 'json', 'docx', 'txt'
    folder_path = File.join(default_folder_path, "archivos.#{extension}")
    Dir.mkdir(folder_path) unless Dir.exist?(folder_path)
    copy_file_path = File.join(folder_path, file_name)
    FileUtils.copy(file_path, copy_file_path)
  else
    copy_file_path = File.join(default_folder_path, file_name)
    FileUtils.copy(file_path, copy_file_path)
  end
end
def show_message(message)
  dialog = setup_message_dialog(message)
  dialog.signal_connect('response') { dialog.close }
  dialog.set_position(Gtk::WindowPosition::CENTER)
  dialog.show_all
end
def setup_message_dialog(message)
  Gtk::MessageDialog.new(
    parent: nil,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::INFO,
    buttons: Gtk::ButtonsType::CLOSE,
    message: message
  )
end
