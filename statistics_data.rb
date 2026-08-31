module StatisticsData
  def self.update_statistics_list(lista_estadisticas)
    total_registros = Logica.obtener_total_registros.to_s
    busquedas_realizadas = Logica.obtener_total_busquedas.to_s
    ediciones_realizadas = Logica.obtener_total_ediciones.to_s
    ultimo_respaldo = Logica.obtener_ultimo_respaldo_automatico
    ultimo_respaldo = ultimo_respaldo&.strftime('%Y-%m-%d %H:%M:%S') if ultimo_respaldo.is_a?(Time)
    copias_seguridad_realizadas = Logica.obtener_total_copias_seguridad_manuales.to_s
    ultima_operacion = UltimaOperacion.obtener_ultima_operacion_realizada || 'N/A'
    busquedas_ventana_historial = Logica.obtener_total_historial.to_s
    busquedas_ventana_baterias = Logica.obtener_total_busquedas_ventana_baterias.to_s
    operaciones_rango_fechas = Logica.contador_rango_fechas.to_s
    lista_estadisticas.clear
    iter = lista_estadisticas.append
    iter[0] = ultima_operacion
    iter[1] = ultimo_respaldo
    iter[2] = total_registros
    iter[3] = busquedas_realizadas
    iter[4] = ediciones_realizadas
    iter[5] = copias_seguridad_realizadas
    iter[6] = busquedas_ventana_historial
    iter[7] = busquedas_ventana_baterias
    iter[8] = operaciones_rango_fechas
  end
end
