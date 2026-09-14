require_relative 'message_helper'
require_relative 'constants'
def handle_invalid_fields(invalid_fields)
  show_message_window("Por favor, completa los campos obligatorios: #{invalid_fields.join(', ')}")
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