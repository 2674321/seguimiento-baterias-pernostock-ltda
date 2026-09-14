# Regenera base_de_datos.db (SOLO local: el archivo está en .gitignore y nunca
# se sube a git) con datos de ejemplo para probar la interfaz.
Dir.chdir(File.expand_path('../..', __dir__))
require 'gtk3'
require 'fileutils'
require_relative '../../database_operations'
require_relative '../../modulo_registro_de_baterias'

FileUtils.rm_f(NOMBRE_DB)
FileUtils.rm_f('Ultima_operacion.yaml')
FileUtils.rm_f('Ultima_copia_de_seguridad_automatica.yaml')
configurar_base_de_datos
configurar_tabla_de_registro

sample_rows = [
  { MODELO: 'YB3L', SERIE: 'A-1001', RECEPCION: '2024/01/15', FACTURA: 'F-001', FECHA_C: '', NC: '', FECHA_NC: '', MOTIVO: '', CLIENTE: 'Juan Pérez', VENDEDOR: 'Ana Gómez', RECARGA: 'cargado', FECHA_ENVIO: '2024/01/20', DESTINO: 'Bogotá', COMENTARIOS: 'Batería nueva entregada a tiempo.' },
  { MODELO: 'YB7B', SERIE: 'B-2002', RECEPCION: '2024/02/03', FACTURA: 'F-002', FECHA_C: '2024/02/05', NC: 27, FECHA_NC: '2024/02/06', MOTIVO: 'Defectuoso', CLIENTE: 'María López', VENDEDOR: 'Carlos Ruiz', RECARGA: 'defectuoso', FECHA_ENVIO: '', DESTINO: 'Medellín', COMENTARIOS: 'Garantía por falla de fábrica.' },
  { MODELO: 'YB10L', SERIE: 'C-3003', RECEPCION: '2024/03/10', FACTURA: 'F-003', FECHA_C: '', NC: '', FECHA_NC: '', MOTIVO: '', CLIENTE: 'Transportes Rápidos', VENDEDOR: 'Ana Gómez', RECARGA: 'descargado', FECHA_ENVIO: '2024/03/14', DESTINO: 'Cali', COMENTARIOS: '' },
  { MODELO: 'YB4L', SERIE: 'D-4004', RECEPCION: '2024/04/22', FACTURA: 'F-004', FECHA_C: '2024/04/25', NC: 12, FECHA_NC: '2024/04/26', MOTIVO: 'Daño en envío', CLIENTE: 'Distribuidora del Sur', VENDEDOR: 'Luis Díaz', RECARGA: 'cargado', FECHA_ENVIO: '', DESTINO: 'Barranquilla', COMENTARIOS: 'Reclamo por transporte.' },
  { MODELO: 'YB5L', SERIE: 'E-5005', RECEPCION: '2024/05/08', FACTURA: 'F-005', FECHA_C: '', NC: '', FECHA_NC: '', MOTIVO: '', CLIENTE: 'Ingeniería Alpha', VENDEDOR: 'Carlos Ruiz', RECARGA: 'en revision', FECHA_ENVIO: '2024/05/12', DESTINO: 'Pereira', COMENTARIOS: 'Se reemplaza por cambio de modelo.' },
  { MODELO: 'YB3L', SERIE: 'F-6006', RECEPCION: '2024/06/19', FACTURA: 'F-006', FECHA_C: '2024/06/21', NC: 3, FECHA_NC: '2024/06/22', MOTIVO: 'Cambio de modelo', CLIENTE: 'AutoPartes Central', VENDEDOR: 'Ana Gómez', RECARGA: 'cargado', FECHA_ENVIO: '', DESTINO: 'Bucaramanga', COMENTARIOS: '' },
  { MODELO: 'YB9L', SERIE: 'G-7007', RECEPCION: '2024/07/02', FACTURA: 'F-007', FECHA_C: '', NC: '', FECHA_NC: '', MOTIVO: '', CLIENTE: 'Servicio Técnico Max', VENDEDOR: 'Luis Díaz', RECARGA: 'cargado', FECHA_ENVIO: '2024/07/05', DESTINO: 'Cartagena', COMENTARIOS: 'Entrega estándar.' }
]

sample_rows.each_with_index do |row, i|
  row[:COMENTARIOS] = "Fila de ejemplo #{i + 1}: #{row[:COMENTARIOS]}"
  DatabaseOperations.insertar_datos(row)
end

db = SQLite3::Database.new(NOMBRE_DB)
total = db.execute('SELECT COUNT(*) FROM tabla_de_datos').first.first
puts "base_de_datos.db regenerada con #{total} filas de ejemplo."
db.close