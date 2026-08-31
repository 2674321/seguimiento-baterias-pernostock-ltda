require_relative 'message_helper'
require_relative 'reemplazo_de_datos'
require_relative 'constants'
require_relative 'edit_database_methods'
require_relative 'edit_save_button_methods'
require_relative 'edit_validation'
require_relative 'edit_window_history_data_insert_module'
require_relative 'edit_window_methods'
require_relative 'edit_window_labels'
require_relative 'validacion_inputs_edit'
require_relative 'limpiar_y_redefinir'
include EditValidation
include ValidationModule
def empezar_reemplazo_de_datos(comment, edit_grid, id)
  save_button_logic(comment, edit_grid, id)
end
def create_edit_window(id = nil)
  @original_field_values = {}
  if @current_edit_window && @current_edit_window.visible?
    show_message('Por favor, cierre la ventana actual antes de abrir otra.')
    return
  end
  edit_window = Gtk::Window.new('Ventana de Edición')
  edit_window.set_size_request(700, 400)
  main_box = Gtk::Box.new(Gtk::Orientation::VERTICAL, 10)
  main_box.set_margin(20)
  edit_grid = Gtk::Grid.new
  edit_grid.column_homogeneous = true
  edit_grid.row_spacing = 10
  edit_grid.column_spacing = 10
  Constants::TablaDeDatos::COLUMN_NAMES.each_with_index do |(_key, value), index|
    case value
    when 'ID'
      display_name = 'ID de la Bateria'
    when 'MODELO'
      display_name = 'Modelo'
    when 'SERIE'
      display_name = 'Serie'
    when 'RECEPCION'
      display_name = 'Recepción'
    when 'FACTURA'
      display_name = 'Factura'
    when 'FECHA_C'
      display_name = 'Fecha Factura'
    when 'NC'
      display_name = 'Nota de Credito'
    when 'FECHA_NC'
      display_name = 'Fecha N.C'
    when 'MOTIVO'
      display_name = 'Motivo de la devolución'
    when 'CLIENTE'
      display_name = 'Cliente'
    when 'VENDEDOR'
      display_name = 'Vendedor'
    when 'RECARGA'
      display_name = 'Recarga'
    when 'FECHA_ENVIO'
      display_name = 'Fecha Envío'
    when 'DESTINO'
      display_name = 'Destino'
    when 'COMENTARIOS'
      display_name = 'Comentarios'
    else
      display_name = value
    end
    label = Gtk::Label.new(display_name.gsub(':', ''))
    label.set_hexpand(true)
    label.set_margin_end(10)
    edit_grid.attach(label, 0, index, 1, 1)
    entry = Gtk::Entry.new
    entry.set_hexpand(true)
    entry.set_margin_end(10)
    entry.max_length = 255
    set_entry_tooltip(entry, display_name)
    case value
    when 'ID'
      entry.placeholder_text = 'ID'
      entry.text = id if id
    when 'MODELO'
      entry.placeholder_text = ''
    when 'SERIE'
      entry.placeholder_text = ''
    when 'RECEPCION'
      entry.placeholder_text = 'AAAA/MM/DD'
    when 'FACTURA'
      entry.placeholder_text = ''
    when 'FECHA_C'
      entry.placeholder_text = 'AAAA/MM/DD'
    when 'NC'
      entry.placeholder_text = ''
    when 'FECHA_NC'
      entry.placeholder_text = 'AAAA/MM/DD'
    when 'MOTIVO'
      entry.placeholder_text = 'Motivo de la devolución (mantenga el mouse por encima)'
    when 'CLIENTE'
      entry.placeholder_text = 'Al menos Nombre y Apellido y/o Nombre de la empresa'
    when 'VENDEDOR'
      entry.placeholder_text = 'Al menos Nombre y Apellido y/o Nombre de la empresa'
    when 'RECARGA'
      entry.placeholder_text = 'Cargado, Descargado, Revisión o Defectuoso'
    when 'FECHA_ENVIO'
      entry.placeholder_text = 'AAAA/MM/DD'
    when 'DESTINO'
      entry.placeholder_text = 'Destino de la bateria'
    when 'COMENTARIOS'
      entry.placeholder_text = 'Agregue/Edite un comentario de la batería'
    else
      entry.placeholder_text = ''
    end
    if [1, 2, 3, 9, 10].include?(index)
      label.text = "#{display_name.gsub(':', '')}: *"
    end
    if index == 0
      edit_grid.attach(entry, 1, index, 1, 1)
      search_button = Gtk::Button.new(label: 'Buscar')
      search_button.set_hexpand(true)
      search_button.set_margin_end(10)
      search_button.set_hexpand(true)
      search_button.set_tooltip_text('Permite buscar la ID de una batería para editar sus datos asociados.')
      edit_grid.attach(search_button, 2, index, 1, 1)
      search_button.signal_connect("clicked") do
        id_input = entry.text.strip
        if id_input.empty?
          show_message('Por favor, ingresa un ID para buscar')
        else
          clear_entry_fields(edit_grid)
          id = id_input
          perform_search(edit_grid, id_input)
        end
      end
      entry.signal_connect("activate") do |widget|
        id_input = widget.text.strip
        if id_input.empty?
          show_message('Por favor, ingresa un ID para buscar')
        else
          clear_entry_fields(edit_grid)
          id = id_input
          perform_search(edit_grid, id_input)
        end
      end
    else
      edit_grid.attach(entry, 1, index, 2, 1)
    end
  end
  button_box = Gtk::ButtonBox.new(Gtk::Orientation::HORIZONTAL)
  button_box.layout = Gtk::ButtonBoxStyle::END
  exit_button = Gtk::Button.new(label: 'Cerrar')
  exit_button.width_request = 150
  exit_button.set_halign(Gtk::Align::CENTER)
  save_button = Gtk::Button.new(label: 'Guardar cambios')
  save_button.width_request = 150
  save_button.set_tooltip_text('Guarda los datos editados para su reintegración en la base de datos.')
  save_button.set_halign(Gtk::Align::CENTER)
  open_window_button = Gtk::Button.new(label: 'Estadísticas')
  open_window_button.width_request = 150
  open_window_button.set_tooltip_text('Abrir la ventana de estadísticas de operaciones')
  open_window_button.signal_connect('clicked') do |_button|
    Interfaz.ventana_de_estadisticas
  end
  exit_button.signal_connect("clicked") do
    edit_window.close
  end
  comment_label = Gtk::Label.new('Motivo de la Edición *')
  comment_label.set_hexpand(true)
  comment_label.set_margin_end(10)
  comment_entry = Gtk::Entry.new
  comment_entry.set_hexpand(true)
  comment_entry.set_margin_end(10)
  comment_entry.set_tooltip_text("Por favor, ingresa el motivo de la edición")
  edit_grid.attach(comment_label, 0, Constants::TablaDeDatos::COLUMN_NAMES.length, 1, 1)
  edit_grid.attach(comment_entry, 1, Constants::TablaDeDatos::COLUMN_NAMES.length, 2, 1)
  button_box = Gtk::ButtonBox.new(Gtk::Orientation::HORIZONTAL)
  button_box.layout = Gtk::ButtonBoxStyle::END
  exit_button = Gtk::Button.new(label: 'Cerrar')
  exit_button.width_request = 150
  exit_button.set_halign(Gtk::Align::CENTER)
  history_button = Gtk::Button.new(label: 'Historial')
  history_button.width_request = 150
  history_button.set_tooltip_text('Muestra el historial de cambios generales y específicos de una batería.')
  history_button.set_halign(Gtk::Align::CENTER)
  open_window_button = Gtk::Button.new(label: 'Estadísticas')
  open_window_button.width_request = 150
  open_window_button.set_tooltip_text('Abrir la ventana de estadísticas de operaciones')
  open_window_button.signal_connect('clicked') do |_button|
    Interfaz.ventana_de_estadisticas
  end
  history_button.signal_connect("clicked") do
    VENTANA_DE_HISTORIAL.new.iniciar_ventana_de_historial
  end
  exit_button.signal_connect("clicked") do
    edit_window.close
  end
  save_button.signal_connect("clicked") do
    errores_comentario = validar_comentario(comment_entry.text)
    if errores_comentario.empty?
      edited_fields = collect_edited_fields(edit_grid, id)
      if validate_edited_fields(edited_fields)
        comment, edit_grid, id = limpiar_y_redefinir(comment_entry.text, edit_grid, id)
        empezar_reemplazo_de_datos(comment, edit_grid, id)
      else
      end
    else
      mostrar_ventana_de_error(errores_comentario)
    end
  end
  comment_entry.signal_connect("activate") do |widget|
    errores_comentario = validar_comentario(comment_entry.text)
    if errores_comentario.empty?
      edited_fields = collect_edited_fields(edit_grid, id)
      if validate_edited_fields(edited_fields)
        comment, edit_grid, id = limpiar_y_redefinir(comment_entry.text, edit_grid, id)
        empezar_reemplazo_de_datos(comment, edit_grid, id)
      else
      end
    else
      mostrar_ventana_de_error(errores_comentario)
    end
  end
  button_box.add(history_button)
  button_box.add(open_window_button)
  button_box.add(exit_button)
  button_box.add(save_button)
  main_box.add(edit_grid)
  main_box.add(button_box)
  edit_window.add(main_box)
  edit_window.signal_connect("destroy") do
    @current_edit_window = nil
  end
  edit_window.set_position(Gtk::WindowPosition::CENTER_ALWAYS)
  edit_window.show_all
  @current_edit_window = edit_window
end
