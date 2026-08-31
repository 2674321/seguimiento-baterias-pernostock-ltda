def guardar_resultados(result_label, window)
  results_text = result_label.text
  dialog = Gtk::FileChooserDialog.new(
    title: 'Guardar Resultados',
    parent: window,
    action: :save,
    buttons: [
      [Gtk::Stock::CANCEL, :cancel],
      [Gtk::Stock::SAVE, :ok]
    ]
  )
  dialog.set_do_overwrite_confirmation(true)
  filter_text = Gtk::FileFilter.new
  filter_text.name = "Archivos de texto (*.txt)"
  filter_text.add_pattern("*.txt")
  dialog.add_filter(filter_text)
  filter_json = Gtk::FileFilter.new
  filter_json.name = "Archivos JSON (*.json)"
  filter_json.add_pattern("*.json")
  dialog.add_filter(filter_json)
  filter_docx = Gtk::FileFilter.new
  filter_docx.name = "Documentos Word (*.docx)"
  filter_docx.add_pattern("*.docx")
  dialog.add_filter(filter_docx)
  filter_csv = Gtk::FileFilter.new
  filter_csv.name = "Archivos CSV (*.csv)"
  filter_csv.add_pattern("*.csv")
  dialog.add_filter(filter_csv)
  filter_all = Gtk::FileFilter.new
  filter_all.name = "Todos los archivos"
  filter_all.add_pattern("*")
  dialog.add_filter(filter_all)
  if dialog.run == :ok
    file_path = dialog.filename
    selected_filter = dialog.filter
    selected_filter_name = selected_filter.name
    extension = ""
    case selected_filter_name
    when "Archivos de texto (*.txt)"
      extension = ".txt"
    when "Archivos JSON (*.json)"
      extension = ".json"
    when "Documentos Word (*.docx)"
      extension = ".docx"
    when "Archivos CSV (*.csv)"
      extension = ".csv"
    end
    begin
      file_path_with_extension = add_extension_to_file(file_path, extension)
      File.open(file_path_with_extension, 'w') { |file| file.write(results_text) }
      show_message_dialog("Guardado", "Los resultados se han guardado en #{file_path_with_extension}")
    rescue StandardError => e
      show_message_dialog("Error", "Error al guardar los resultados: #{e.message}")
    end
    copy_to_folder(file_path_with_extension, extension)
  end
  dialog.destroy
end
def add_extension_to_file(file_path, extension)
  if File.extname(file_path) != extension
    file_path += extension
  end
  file_path
end
def copy_to_folder(file_path, extension)
  current_folder = File.dirname(__FILE__)
  saved_files_folder = File.join(current_folder, 'archivos_guardados', extension[1..-1])
  Dir.mkdir(saved_files_folder) unless File.directory?(saved_files_folder)
  file_name = File.basename(file_path)
  new_file_path = File.join(saved_files_folder, file_name)
  FileUtils.cp(file_path, new_file_path)
end
