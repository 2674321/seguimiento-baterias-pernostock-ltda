def handle_search_error(error)
  puts "Error en la búsqueda: #{error.message}"
  raise "Error en la búsqueda: #{error.message}"
end
def flexible_validator(value, allowed_values)
  normalized_value = value.to_s.downcase.strip.gsub(/\s+/, '')
  normalized_allowed_values = allowed_values.map { |v| v.downcase.strip.gsub(/\s+/, '') }
  normalized_value.empty? || normalized_allowed_values.include?(normalized_value)
end
def handle_invalid_fields(invalid_fields)
  show_message_window("Por favor, completa los campos obligatorios: #{invalid_fields.join(', ')}")
end
def show_message_window(message)
  if @message_window.nil?
    @message_window = Gtk::MessageDialog.new(
      transient_for: @current_edit_window,
      flags: Gtk::DialogFlags::MODAL,
      type: Gtk::MessageType::INFO,
      buttons: Gtk::ButtonsType::OK,
      message: message
    )
    @message_window.signal_connect("response") { @message_window.close }
    @message_window.show_all
    @message_window.set_position(:center)
  else
    @message_window.set_text(message)
  end
end
def clear_search_fields(edit_grid)
  id_entry = edit_grid.get_child_at(1, 0)
  id_entry.text = ''
end
def clear_entry_fields(edit_grid)
  Constants::TablaDeDatos::COLUMN_NAMES.each_with_index do |(_key, value), index|
    next if value == 'ID'
    entry = edit_grid.get_child_at(1, index)
    entry.text = ''
  end
end
module EditValidation
  def validar_comentario(comment)
    errores_comentario = []
    errors = []
    if comment.nil?
      errors << "El comentario no puede estar vacío."
    elsif comment =~ /^\d+$/
      errors << "El comentario puede contener texto y números, pero no solo números."
    end
    errors
  end
end
def mostrar_ventana_de_error(errors)
  dialog = Gtk::MessageDialog.new(
    parent: @current_edit_window,
    flags: Gtk::DialogFlags::MODAL,
    type: Gtk::MessageType::WARNING,
    buttons: Gtk::ButtonsType::OK,
    message: "Errores:"
  )
  dialog.secondary_text = ""
  errors.each_with_index do |error, index|
    dialog.secondary_text += "#{index + 1}. #{error}\n"
  end
  dialog.run
  dialog.destroy
end
