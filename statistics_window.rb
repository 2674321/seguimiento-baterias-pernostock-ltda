require 'gtk3'
require 'sqlite3'
require_relative 'database_operations'
require_relative 'statistics_logic'
require_relative 'statistics_data'
module Interfaz
  extend StatisticsData
  def self.crear_segundo_treeview
    subtitle_label_2 = Gtk::Label.new('Estadísticas de las baterías en la base de datos')
    subtitle_label_2.halign = :start
    subtitle_label_2.valign = :start
    lista_estadisticas_2 = Gtk::ListStore.new(String, String)
    tree_view_2 = Gtk::TreeView.new(lista_estadisticas_2)
    tree_view_2.set_headers_visible(true)
    tree_view_2.set_rules_hint(true)
    tree_view_2.set_width_request(-1)
    columns = ['Modelo', 'Cant. Modelo']
    columns.each_with_index do |col_title, col|
      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new(col_title, renderer, text: col)
      column.set_sizing(Gtk::TreeViewColumnSizing::AUTOSIZE)
      tree_view_2.append_column(column)
    end
    add_data_from_database(lista_estadisticas_2)
    scrolled_window_2 = Gtk::ScrolledWindow.new
    scrolled_window_2.add(tree_view_2)
    box_2 = Gtk::Box.new(:vertical, 5)
    box_2.pack_start(subtitle_label_2, expand: false, fill: false, padding: 5)
    box_2.pack_start(scrolled_window_2, expand: true, fill: true, padding: 0)
    return box_2
  end
  def self.add_data_from_database(lista_estadisticas_2)
    db = SQLite3::Database.new 'base_de_datos.db'
    query = "SELECT MODELO, COUNT(*) AS Cantidad FROM tabla_de_datos GROUP BY MODELO"
    results = db.execute(query)
    results.each do |row|
      iter = lista_estadisticas_2.append
      iter.set_value(0, row[0].downcase)
      iter.set_value(1, row[1].to_s)
    end
    db.close
  end
  def self.ventana_de_estadisticas
    begin
      statistics_window = Gtk::Window.new('Ventana de Estadísticas')
      statistics_window.set_default_size(500, 580)
      statistics_window.set_position(Gtk::WindowPosition::CENTER_ALWAYS)
      title_label = Gtk::Label.new('Estadísticas del Programa')
      subtitle_label = Gtk::Label.new('Las estadísticas de recuento son por ejecución del programa.')
      title_label.halign = :start
      title_label.valign = :start
      subtitle_label.halign = :start
      subtitle_label.valign = :start
      title_box = Gtk::Box.new(:horizontal, 10)
      title_box.pack_start(title_label, expand: false, fill: false, padding: 5)
      title_box.pack_start(subtitle_label, expand: false, fill: false, padding: 5)
      lista_estadisticas = Gtk::ListStore.new(String, String, String, String, String, String, String, String, String)
      tree_view = Gtk::TreeView.new(lista_estadisticas)
      tree_view.set_headers_visible(true)
      tree_view.set_rules_hint(true)
      tree_view.set_width_request(-1)
      columns = ['Últ. Operación Realizada', 'Ult. Respaldo Automático', 'Reg. Totales', 'Búsq. totales', 'Edic. totales', 'Cant. Cop. Seguridad', 'Búsq. Vent. Historial', 'Búsq. Vent. Baterias', 'Op. Rang. de Fechas']
      columns.each_with_index do |col_title, col|
        renderer = Gtk::CellRendererText.new
        column = Gtk::TreeViewColumn.new(col_title, renderer, text: col)
        column.set_sizing(Gtk::TreeViewColumnSizing::AUTOSIZE)
        tree_view.append_column(column)
      end
      scrolled_window = Gtk::ScrolledWindow.new
      scrolled_window.add(tree_view)
      box = Gtk::Box.new(:vertical, 5)
      time_label = Gtk::Label.new
      time_label.halign = :end
      time_label.valign = :start
      time_label.margin_right = 10
      update_time_label = lambda do
        return unless time_label && !time_label.destroyed?
        current_time = Time.now
        formatted_time = current_time.strftime("%Y-%m-%d %H:%M:%S")
        time_label.text = "#{formatted_time}"
      end
      update_time_label.call
      GLib::Timeout.add_seconds(1) { update_time_label.call; true }
      time_box = Gtk::Box.new(:horizontal, 10)
      time_box.pack_end(time_label, expand: false, fill: false, padding: 5)
      update_button = Gtk::Button.new
      update_button_label = Gtk::Label.new("Actualizar Estadísticas")
      update_button_label.set_padding(5, 0)
      update_button_icon = Gtk::Image.new(icon_name: "view-refresh", icon_size: Gtk::IconSize::BUTTON)
      update_button_container = Gtk::Box.new(:horizontal, 5)
      update_button_container.pack_start(update_button_icon, expand: false, fill: true, padding: 0)
      update_button_container.pack_start(update_button_label, expand: false, fill: true, padding: 0)
      update_button.add(update_button_container)
      update_button.signal_connect('clicked') do
        StatisticsData.update_statistics_list(lista_estadisticas)
        lista_estadisticas.each do |model, path, iter|
        end
      end
      time_box.pack_start(update_button, expand: false, fill: false, padding: 5)
      box.pack_start(title_box, expand: false, fill: false, padding: 5)
      box.pack_end(time_box, expand: false, fill: false, padding: 5)
      box.pack_start(scrolled_window, expand: true, fill: true, padding: 0)
      box.pack_start(crear_segundo_treeview, expand: true, fill: true, padding: 0)
      statistics_window.add(box)
      statistics_window.signal_connect('destroy') do
      end
      statistics_window.show_all
    rescue StandardError => e
      e.backtrace.each { |line| puts line }
    end
  end
end
