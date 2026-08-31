require_relative 'history_data'
require_relative 'history_search'
require_relative 'message_helper'
require_relative 'history_window_interface'
require 'gtk3'
class VENTANA_DE_HISTORIAL
  def initialize
    @history_window_open = false
  end
  def update_history_data
    history_data = HistoryData.get_data_from_database
    update_history_view(history_data)
  end
end
