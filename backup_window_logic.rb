require 'gtk3'
require 'fileutils'
require_relative 'database_loader'
require_relative 'dialog_helper'
def show_error_dialog(message)
  DialogHelper.show_error('Error', message)
end
def show_info_dialog(message)
  DialogHelper.show_info('Información', message)
end
def show_confirmation_dialog(window)
  DialogHelper.show_confirmation('¿Estás seguro de que quieres realizar la copia de seguridad?', parent: window)
end