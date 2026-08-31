require 'gtk3'
require 'glib2'
require_relative 'message_helper'
require_relative 'statistics_logic'
require_relative 'statistics_data'
NOMBRES_BATTERY_WINDOW_STAT = {
  ID: 'ID Bateria',
  MODELO: 'Modelo',
  SERIE: 'Número de Serie',
  RECEPCION: 'Fecha de Recepción',
  FACTURA: 'Número de Factura',
  FECHA_FACTURA: 'Fecha de Factura',
  NC: 'Número de Nota de Crédito',
  FECHA_NC: 'Fecha de Nota de Crédito',
  MOTIVO: 'Motivo',
  CLIENTE: 'Cliente',
  VENDEDOR: 'Vendedor',
  RECARGA: 'Recarga',
  FECHA_ENVIO: 'Fecha de Envío',
  DESTINO: 'Destino',
  COMENTARIOS: 'Comentarios'
}
def show_message_window(message)
  GLib::Idle.add do
    begin
      dialog = Gtk::MessageDialog.new(
        parent: nil,
        flags: Gtk::DialogFlags::MODAL,
        type: Gtk::MessageType::INFO,
        buttons: Gtk::ButtonsType::OK,
        message: message
      )
      dialog.run
      dialog.destroy
    rescue StandardError => e
      puts "Error showing message window: #{e.message}"
      puts e.backtrace.join("\n")
    end
    GLib::Source::REMOVE
  end
end
def buscar_en_battery_window(column_index, search_text, battery_data, list_store)
  if search_text.empty?
    show_message_window("Por favor, ingrese un término de búsqueda válido.")
    return
  end
  Logica.incrementar_contador_busquedas_ventana_baterias
  Logica.incrementar_contador_busquedas
  matching_data = battery_data.select do |data|
    data[column_index].to_s.downcase.include?(search_text.downcase)
  end
  if matching_data.empty?
    show_message_window("No se encontraron resultados para: #{search_text}")
  else
    update_battery_view(list_store, matching_data)
    column_name = NOMBRES_BATTERY_WINDOW_STAT.keys[column_index]
    result_text = matching_data.first(5).map { |data| data[column_index] }.join(', ')
    result_text += ', ...' if matching_data.size > 5
    cantidad_resultados = matching_data.size
    show_message_window("Búsqueda realizada en la ventana de baterías con éxito:\nInput: #{search_text}\nColumna: #{NOMBRES_BATTERY_WINDOW_STAT[column_name]}\nResultados (#{cantidad_resultados}): #{result_text}")
    UltimaOperacion.actualizar_ultima_operacion_realizada("Búsqueda realizada en la ventana de baterías con éxito:\nInput: #{search_text}\nColumna: #{NOMBRES_BATTERY_WINDOW_STAT[column_name]}\nResultados (#{cantidad_resultados}): #{result_text}")
  end
end
