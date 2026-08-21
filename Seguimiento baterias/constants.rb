require 'sqlite3'
MAX_LONGITUD_GENERAL = 256
INDICATOR_TABLE_NAME = 'indicadores'.freeze
NOMBRE_DB = 'base_de_datos.db'.freeze
TABLE_CREATED_FLAG = 'flag_de_creacion_de_tabla'.freeze
module Constants
  module TablaDeDatos
    COLUMN_NAMES = {
      ID: 'ID',
      MODELO: 'MODELO',
      SERIE: 'SERIE',
      RECEPCION: 'RECEPCION',
      FACTURA: 'FACTURA',
      FECHA_C: 'FECHA_C',
      NC: 'NC',
      FECHA_NC: 'FECHA_NC',
      MOTIVO: 'MOTIVO',
      CLIENTE: 'CLIENTE',
      VENDEDOR: 'VENDEDOR',
      RECARGA: 'RECARGA',
      FECHA_ENVIO: 'FECHA_ENVIO',
      DESTINO: 'DESTINO',
      COMENTARIOS: 'COMENTARIOS'
    }.freeze
  end
  module TablaDeRegistro
    COLUMN_NAMES_REGISTRO = {
      ID: 'ID',
      FECHA_HORA: 'FECHA_HORA',
      CAMPO_MODIFICADO: 'CAMPO_MODIFICADO',
      VALOR_ANTERIOR: 'VALOR_ANTERIOR',
      VALOR_NUEVO: 'VALOR_NUEVO',
      RAZON_CAMBIO: 'RAZON_CAMBIO',
      ID_BATERIA: 'ID_BATERIA'
    }.freeze
  end
end
