require 'gtk3'
module Calendario
  def self.show_calendar
    window = Gtk::Window.new
    window.set_title('Calendario')
    window.set_default_size(400, 200)
    window.set_border_width(10)
    window.signal_connect('delete-event') { Gtk.main_quit }
    calendar = Gtk::Calendar.new
    window.add(calendar)
    window.set_window_position(Gtk::WindowPosition::CENTER)
    window.show_all
    Gtk.main
  end
end
