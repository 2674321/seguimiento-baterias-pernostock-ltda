require_relative 'constants'
require_relative 'reemplazo_de_datos'
require_relative 'history_helper'
require_relative 'message_helper'
require_relative 'edit_window_interface'
require_relative 'edit_window_history_data_insert_module'
require_relative 'edit_window_methods'
require_relative 'edit_save_button_methods'
require_relative 'edit_validation'
require_relative 'edit_database_methods'
@message_window = nil
@current_edit_window = nil
@history_window_open = false
@edited_inputs = []
def iniciar_ventana_de_edicion
  create_edit_window
end
