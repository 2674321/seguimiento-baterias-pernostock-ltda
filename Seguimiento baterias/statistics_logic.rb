require 'yaml'
module Logica
  @@contador_registros = 0
  @@contador_busquedas = 0
  @@contador_busquedas_ventana_baterias = 0
  @@contador_ediciones = 0
  @@ultimo_respaldo_automatico = nil
  @@contador_historial = 0
  @@contador_copias_seguridad_manuales = 0
  @registros_editados = {}
  @@contador_rango_fechas = 0
  def self.incrementar_contador_registros
    @@contador_registros += 1
  end
  def self.obtener_total_registros
    @@contador_registros
  end
  def self.incrementar_contador_ediciones
    @@contador_ediciones += 1
  end
  def self.obtener_total_ediciones
    @@contador_ediciones
  end
  def self.incrementar_contador_busquedas
    @@contador_busquedas += 1
  end
  def self.obtener_total_busquedas
    @@contador_busquedas
  end
  def self.actualizar_ultimo_respaldo_automatico(timestamp)
    @@ultimo_respaldo_automatico = timestamp
  end
  def self.obtener_ultimo_respaldo_automatico
    @@ultimo_respaldo_automatico
  end
  def self.incrementar_contador_copias_seguridad_manuales
    @@contador_copias_seguridad_manuales += 1
  end
  def self.obtener_total_copias_seguridad_manuales
    @@contador_copias_seguridad_manuales
  end
  def self.incrementar_contador_historial
    @@contador_historial += 1
  end
  def self.obtener_total_historial
    @@contador_historial
  end
  def self.incrementar_contador_busquedas_ventana_baterias
    @@contador_busquedas_ventana_baterias += 1
  end
  def self.obtener_total_busquedas_ventana_baterias
    @@contador_busquedas_ventana_baterias
  end
  def self.incrementar_contador_rango_fechas
    @@contador_rango_fechas += 1
  end
  def self.contador_rango_fechas
    @@contador_rango_fechas
  end
end
module UltimaOperacion
  @@ultima_operacion_realizada = nil
  def self.actualizar_ultima_operacion_realizada(operacion)
    @@ultima_operacion_realizada = operacion
    guardar_en_yaml
  end
  def self.obtener_ultima_operacion_realizada
    leer_desde_yaml unless @@ultima_operacion_realizada
    @@ultima_operacion_realizada
  end
  private
  def self.guardar_en_yaml
    begin
      ruta_archivo = File.join(File.dirname(__FILE__), 'Ultima_operacion.yaml')
      data = { ultima_operacion: @@ultima_operacion_realizada }
      File.open(ruta_archivo, 'w:utf-8') do |file|
        file.write(data.to_yaml)
      end
    rescue StandardError => e
     # puts "ERROR: No se pudo guardar en YAML. Mensaje de error: #{e.message}"
      puts "ERROR: Backtrace: #{e.backtrace.join("\n")}"
    end
  end
  def self.leer_desde_yaml
    begin
      ruta_archivo = File.join(File.dirname(__FILE__), 'Ultima_operacion.yaml')
      if File.exist?(ruta_archivo)
        data = YAML.load_file(ruta_archivo)
        @@ultima_operacion_realizada = data[:ultima_operacion]
      end
    rescue StandardError => e
     # puts "ERROR: No se pudo leer desde YAML. Mensaje de error: #{e.message}"
      puts "ERROR: Backtrace: #{e.backtrace.join("\n")}"
    end
  end
end
NOMBRES_CAMPOS = {
  ID: 'Identificador',
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
def recolectar_datos_ultima_operacion(column_entries, comment_entry)
  ultimos_datos_recopilados = []
  NOMBRES_CAMPOS.each do |campo, display_name|
    entry = column_entries[campo]
    if entry
      text = entry.text
      case display_name
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
        display_name = display_name
      end
      ultimos_datos_recopilados << "- #{display_name}: #{text}"
    end
  end
  ultimos_datos_recopilados << "- Comentarios: #{comment_entry.text}"
  result_string = ultimos_datos_recopilados.join("\n")
  puts result_string
  UltimaOperacion.actualizar_ultima_operacion_realizada(result_string)
end
