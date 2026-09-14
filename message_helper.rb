require 'gtk3'
require_relative 'dialog_helper'
module MessageHelper
  def self.show_message_window(message, main_window = nil)
    DialogHelper.show_info('Mensaje', message, parent: main_window)
  end
end
def show_message_window(message, parent = nil)
  MessageHelper.show_message_window(message, parent || @current_edit_window)
end
def show_message(message)
  MessageHelper.show_message_window(message)
end
def handle_search_error(error)
  MessageHelper.show_message_window("Error en la búsqueda: #{error.message}")
end
def mostrar_ventana_de_error(errors)
  DialogHelper.show_warning('Errores:', nil, parent: @current_edit_window, secondary: errors.each_with_index.map { |error_text, index| "#{index + 1}. #{error_text}" }.join("\n"))
end