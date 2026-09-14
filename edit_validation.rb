def flexible_validator(value, allowed_values)
  normalized_value = value.to_s.downcase.strip.gsub(/\s+/, '')
  normalized_allowed_values = allowed_values.map { |v| v.downcase.strip.gsub(/\s+/, '') }
  normalized_value.empty? || normalized_allowed_values.include?(normalized_value)
end
def handle_invalid_fields(invalid_fields)
  show_message_window("Por favor, completa los campos obligatorios: #{invalid_fields.join(', ')}")
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
    errors = []
    if comment.nil?
      errors << "El comentario no puede estar vacío."
    elsif comment =~ /^\d+$/
      errors << "El comentario puede contener texto y números, pero no solo números."
    end
    errors
  end
end