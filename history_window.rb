require 'gtk3'
require_relative 'history_data'
require_relative 'history_search'
require_relative 'message_helper'
require_relative 'history_window_interface'
class VENTANA_DE_HISTORIAL
  def initialize
    @history_window_open = false
  end
  def iniciar_ventana_de_historial
    create_history_window
  end
end