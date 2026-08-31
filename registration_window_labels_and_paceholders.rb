def label_text(value)
  case value
  when 'MODELO' then 'Modelo de la batería *'
  when 'SERIE' then 'Número de Serie *'
  when 'RECEPCION' then 'Fecha de Recepción *'
  when 'FACTURA' then 'Número de Factura'
  when 'FECHA_C' then 'Fecha de la Factura'
  when 'NC' then 'Nota de Crédito'
  when 'FECHA_NC' then 'Fecha de la Nota de Crédito'
  when 'MOTIVO' then 'Motivo de Devolución'
  when 'CLIENTE' then 'Nombre del Cliente *'
  when 'VENDEDOR' then 'Nombre del Vendedor *'
  when 'RECARGA' then 'Estado de Recarga'
  when 'FECHA_ENVIO' then 'Fecha de Envío'
  when 'DESTINO' then 'Lugar de Destino'
  when 'COMENTARIOS' then 'Comentario sobre la bateria (Opcional)'
  else ''
  end
end
def placeholder_text(value)
  case value
  when 'MODELO' then ''
  when 'SERIE' then ''
  when 'RECEPCION' then ''
  when 'FACTURA' then ''
  when 'FECHA_RECEPCION' then 'AAAA/MM/DD'
  when 'FECHA_C' then 'AAAA/MM/DD'
  when 'NC' then ''
  when 'FECHA_NC' then 'AAAA/MM/DD'
  when 'MOTIVO' then 'Motivo de la devolucion'
  when 'CLIENTE' then 'Al menos Nombre y Apellido y/o Nombre de la empresa'
  when 'VENDEDOR' then 'Al menos Nombre y Apellido y/o Nombre de la empresa'
  when 'RECARGA' then 'Cargado, Descargado, Revisión o Defectuoso'
  when 'FECHA_ENVIO' then 'AAAA/MM/DD'
  when 'DESTINO' then 'Destino de la bateria'
  when 'COMENTARIOS' then 'Agregue un comentario al registrar la batería (opcional)'
  else ''
  end
end
def tooltip_text(key)
  case key
  when :MODELO then 'Ingrese el modelo de la batería'
  when :SERIE then 'Ingrese el número de serie de la batería'
  when :RECEPCION then "Formato (AAAA/MM/DD)\nEj: 2024/11/31"
  when :FACTURA then 'Ingrese el número de factura'
  when :FECHA_C then "Formato (AAAA/MM/DD)\nEj: 2024/11/31"
  when :NC then 'Ingrese el número de Nota de Crédito'
  when :FECHA_NC then "Formato (AAAA/MM/DD)\nEj: 2024/11/31"
  when :MOTIVO then 'Ingrese el motivo de devolución (Estados permitidos:' \
    "\n- Funcional (Devuelta pero sigue funcional)" \
    "\n- Cambio de modelo" \
    "\n- Defectuoso" \
    "\n- Problema de fábrica" \
    "\n- Daño en el envío" \
    "\n- Cambio de modelo" \
    "\n- Incompatible"
  when :CLIENTE then "Ingrese el nombre del Cliente\n('Al menos Nombre y Apellido y/o Nombre de la empresa')"
  when :VENDEDOR then "Ingrese el nombre del Vendedor\n('Al menos Nombre y Apellido y/o Nombre de la empresa')"
  when :RECARGA then "Ingrese el estado de recarga\n" \
    "- Cargado\n" \
    "- Descargado\n" \
    "- En revisión\n" \
    "- Defectuoso"
  when :FECHA_ENVIO then 'Ingrese la fecha de envío (AAAA/MM/DD)'
  when :DESTINO then 'Ingrese el lugar de destino de la batería'
  when :COMENTARIOS then 'Agregue un comentario al registrar la batería (opcional)'
  else ''
  end
end
