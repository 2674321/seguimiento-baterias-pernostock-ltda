require_relative 'statistics_logic'
class HistorySearch
  COLUMNS = ['ID CAMBIO', 'Fecha y Hora', 'Campo Modificado', 'Valores Anteriores', 'Valores Nuevos', 'Razón Cambio', 'ID BATERIA']
  def self.search_history(history_data, search_text, column_index, list_store)
    if !search_text.empty?
      matching_data = history_data.select do |data|
        data[column_index].to_s.downcase.include?(search_text.downcase)
      end
      if matching_data.empty?
        MessageHelper.show_message_window("No se encontraron resultados para: #{search_text}")
      else
        Logica.incrementar_contador_historial
        update_history_view(list_store, matching_data)
        column_name = COLUMNS[column_index]
        result_text = matching_data.first(5).map { |data| data[column_index] }.join(', ')
        result_text += ', ...' if matching_data.size > 5
        MessageHelper.show_message_window("Búsqueda realizada en la ventana de historial con éxito:\nInput: #{search_text}\nColumna: #{column_name}\nResultados (#{matching_data.size}): #{result_text}")
        UltimaOperacion.actualizar_ultima_operacion_realizada("Búsqueda realizada en la ventana de historial con éxito:\nInput: #{search_text}\nColumna: #{column_name}\nResultados (#{matching_data.size}): #{result_text}")
      end
    else
      MessageHelper.show_message_window("Por favor, ingrese un término de búsqueda válido.")
    end
  end
end
