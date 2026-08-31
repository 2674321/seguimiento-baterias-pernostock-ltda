require_relative 'date_search_window'
require 'gtk3'
class LogicaMenuDateWindow
  def create_date_window(date_button, date_entry_box)
    date_search_window = DateSearchWindow.new(date_entry_box)
    date_search_window.interfaz_date_search_window
  end
end
