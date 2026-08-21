require_relative 'battery_window_logic'
require_relative 'battery_window_interface'
require_relative 'statistics_window'
require_relative 'constants'
require_relative 'database_operations'
require_relative 'message_helper'
require_relative 'interface_setup'
module BatteryWindow
  def self.initialize_interface
    obtener_datos_baterias
    @battery_window_open = false
    create_battery_window
  end
end
