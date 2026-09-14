require 'time'
require 'yaml'
module Logica
  @@contador_registros = 0
  @@contador_busquedas = 0
  @@contador_busquedas_ventana_baterias = 0
  @@contador_ediciones = 0
  @@ultimo_respaldo_automatico = nil
  @@contador_historial = 0
  @@contador_copias_seguridad_manuales = 0
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
    ruta_archivo = File.join(__dir__, 'Ultima_operacion.yaml')
    File.open(ruta_archivo, 'w:utf-8') do |file|
      file.write({ ultima_operacion: @@ultima_operacion_realizada }.to_yaml)
    end
  rescue StandardError => e
    puts "ERROR: No se pudo guardar en YAML. #{e.message}"
  end
  def self.leer_desde_yaml
    ruta_archivo = File.join(__dir__, 'Ultima_operacion.yaml')
    if File.exist?(ruta_archivo)
      data = YAML.load_file(ruta_archivo)
      @@ultima_operacion_realizada = data[:ultima_operacion]
    end
  rescue StandardError => e
    puts "ERROR: No se pudo leer desde YAML. #{e.message}"
  end
end
NOMBRES_CAMPOS = {
  ID: 'ID de la Bateria',
  MODELO: 'Modelo',
  SERIE: 'Serie',
  RECEPCION: 'Recepción',
  FACTURA: 'Factura',
  FECHA_C: 'Fecha Factura',
  NC: 'Nota de Credito',
  FECHA_NC: 'Fecha N.C',
  MOTIVO: 'Motivo de la devolución',
  CLIENTE: 'Cliente',
  VENDEDOR: 'Vendedor',
  RECARGA: 'Recarga',
  FECHA_ENVIO: 'Fecha Envío',
  DESTINO: 'Destino',
  COMENTARIOS: 'Comentarios'
}.freeze
def recolectar_datos_ultima_operacion(column_entries, comment_entry)
  lineas = NOMBRES_CAMPOS.each_with_object([]) do |(campo, display_name), acc|
    entry = column_entries[campo]
    acc << "- #{display_name}: #{entry.text}" if entry
  end
  lineas << "- Comentarios: #{comment_entry.text}"
  resultado = lineas.join("\n")
  puts resultado
  UltimaOperacion.actualizar_ultima_operacion_realizada(resultado)
end