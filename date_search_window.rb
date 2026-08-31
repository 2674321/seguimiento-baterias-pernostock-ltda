require 'gtk3'
require_relative 'search_logic'
require_relative 'constants'
require_relative 'interface_setup'
require_relative 'date_search_validators'
require_relative 'statistics_logic'
class DateSearchWindow
  include SearchLogic
  def initialize(date_entry_box)
    @date_entry_box = date_entry_box
    @tree_view = Gtk::TreeView.new
    build_ui
  end

  def interfaz_date_search_window
    @main_window.show_all
    Gtk.main
  end
  private
  def show_error_message(error_type, custom_message = nil)
    message = case error_type
              when :empty_fields
                custom_message || "Por favor, complete ambos campos de fecha."
              when :invalid_format
                custom_message || "Ingrese fechas válidas en formato AAAA/MM/DD."
              when :same_dates
                custom_message || "Las fechas de inicio y fin no pueden ser iguales, mantenga un minimo un 1 dia de diferencia."
              when :invalid_dates
                custom_message || "Las fechas no son válidas o están fuera del rango permitido."
              when :invalid_length
                custom_message || "La longitud del string excede el máximo permitido."
              when :invalid_year_range
                custom_message || "El año debe estar entre 1800 y 2050."
              when :invalid_month_range
                custom_message || "El mes debe estar entre 1 y 12."
              when :invalid_day
                custom_message || "El día no es válido para el mes y año dados."
              else
                "Las fechas no son válidas o están fuera del rango permitido."
              end
    dialog = Gtk::MessageDialog.new(
      parent: @main_window,
      flags: Gtk::DialogFlags::DESTROY_WITH_PARENT,
      type: Gtk::MessageType::ERROR,
      buttons: Gtk::ButtonsType::OK,
      message: message
    )
    dialog.run
    dialog.destroy
  end
  def build_ui
    @main_window = Gtk::Window.new('Date Search')
    @main_window.signal_connect('destroy') { Gtk.main_quit }
    style_context = @main_window.style_context
    style_context.add_class('linked')
    @main_window.set_default_size(400, 500)
    @main_window.set_position(Gtk::WindowPosition::CENTER)
    box = Gtk::Box.new(:vertical, 5)
    start_label = Gtk::Label.new('Fecha de inicio:')
    start_entry = Gtk::Entry.new
    start_entry.placeholder_text = 'AAAA/MM/DD'
    start_entry.tooltip_text = 'Ingrese la fecha mínima en formato AAAA/MM/DD'
    end_label = Gtk::Label.new('Fecha de fin:')
    end_entry = Gtk::Entry.new
    end_entry.placeholder_text = 'AAAA/MM/DD'
    end_entry.tooltip_text = 'Ingrese la fecha máxima en formato AAAA/MM/DD'
    start_entry.set_margin_bottom(5)
    end_entry.set_margin_bottom(5)
    column_select = Gtk::ComboBoxText.new
    ["Todas", "RECEPCION", "FECHA_C", "FECHA_NC", "FECHA_ENVIO"].each do |value|
      column_select.append_text(value)
    end
    column_select.active = 0
    column_select.tooltip_text = 'Seleccione una columna para buscar'
    column_select.set_margin_bottom(10)
    button_box = Gtk::ButtonBox.new(:horizontal)
    button_box.layout_style = Gtk::ButtonBoxStyle::CENTER
    button = Gtk::Button.new(label: 'Buscar')
    button.tooltip_text = 'Realizar búsqueda'
    scroll = Gtk::ScrolledWindow.new
    scroll.set_policy(:automatic, :automatic)
    @tree_view = Gtk::TreeView.new
    @tree_view.headers_visible = true
    @tree_view.selection.mode = Gtk::SelectionMode::SINGLE
    scroll.add(@tree_view)
    @tree_view.signal_connect('button_press_event') do |widget, event|
      if event.button == Gdk::BUTTON_SECONDARY
        menu = Gtk::Menu.new
        item = Gtk::MenuItem.new(label: 'Eliminar (Interfaz)')
        item.signal_connect('activate') do
          delete_selected_data
        end
        menu.append(item)
        menu.show_all
        menu.popup(nil, nil, event.button, event.time)
      end
    end
    button_box.add(button)
    button.signal_connect('clicked') do
      start_date = start_entry.text
      end_date = end_entry.text
      begin
        if start_date.empty? || end_date.empty?
          show_error_message(:empty_fields)
        elsif !DateSearchValidators.valid_date?(start_date) || !DateSearchValidators.valid_date?(end_date)
          show_error_message(:invalid_format)
        elsif start_date == end_date
          show_error_message(:same_dates)
        elsif !DateSearchValidators.valid_sensible_combined_date?(start_date) || !DateSearchValidators.valid_sensible_combined_date?(end_date)
          show_error_message(:invalid_dates)
        else
          selected_column = column_select.active_text
          results = handle_search_button(start_date, end_date, selected_column)
          Logica.incrementar_contador_busquedas
          Logica.incrementar_contador_rango_fechas
          show_search_results(results)
        end
      rescue ValidationError => e
        show_error_message(nil, e.message)
      rescue => e
        show_error_message(nil, e.message)
      end
    end
    box.pack_start(column_select, expand: false, fill: false, padding: 0)
    box.pack_start(start_label, expand: false, fill: false, padding: 0)
    box.pack_start(start_entry, expand: false, fill: false, padding: 0)
    box.pack_start(end_label, expand: false, fill: false, padding: 0)
    box.pack_start(end_entry, expand: false, fill: false, padding: 0)
    box.pack_start(button_box, expand: false, fill: false, padding: 0)
    box.pack_start(scroll, expand: true, fill: true, padding: 5)
    @main_window.add(box)
    @main_window.show_all
    def delete_selected_data
      selection = @tree_view.selection
      if selection.count_selected_rows > 0
        selected_iter = selection.selected
        @tree_view.model.remove(selected_iter)
      else
        show_error_message(:no_battery_selected, "Por favor, seleccione una fila para eliminar.")
      end
    end
  end
  def show_search_results(results)
    store = Gtk::ListStore.new(String, String, String)
    @tree_view.columns.each do |column|
      @tree_view.remove_column(column)
    end
    if results.empty?
      dialog = Gtk::MessageDialog.new(
        parent: nil,
        flags: Gtk::DialogFlags::DESTROY_WITH_PARENT,
        type: Gtk::MessageType::INFO,
        buttons: Gtk::ButtonsType::CLOSE,
        message: "No se encontraron resultados."
      )
      dialog.run
      dialog.destroy
    else
      results.each do |column_name, rows|
        rows.each do |row|
          id = row[0]
          fecha = row[1]
          iter = store.append
          iter.set_values([id.to_s, column_name.to_s, fecha.to_s])
        end
      end
    end
    columns = ['ID Bateria', 'Columna', 'Fecha']
    columns.each_with_index do |title, i|
      renderer = Gtk::CellRendererText.new
      column = Gtk::TreeViewColumn.new(title, renderer, text: i)
      @tree_view.append_column(column)
      column.clickable = true
      column.signal_connect('clicked') do |_widget|
        sort_column(i)
      end
    end
    @tree_view.model = store
  end
  def sort_column(column_index)
    model = @tree_view.model
    sorted_data = []
    model.each do |model, path, iter|
      sorted_data << [model.get_value(iter, 0), model.get_value(iter, 1), model.get_value(iter, 2)]
    end
    sorted_data.sort_by! { |row| row[1].to_i }
    sorted_data.reverse! if @last_sorted_column == column_index && @last_sorted_order == :asc
    model.clear
    sorted_data.each do |row|
      iter = model.append
      iter.set_values(row)
    end
    @last_sorted_column = column_index
    @last_sorted_order = (@last_sorted_order == :asc ? :desc : :asc)
  end
end
