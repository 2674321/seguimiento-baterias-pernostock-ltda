require 'gtk3'
Gtk.init
theme = Gtk::IconTheme.default
icons = theme.icons
puts "Iconos disponibles:"
puts icons
puts "Presiona Enter para salir..."
$stdin.gets
Gtk.main_quit
