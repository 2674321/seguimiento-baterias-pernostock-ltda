def set_entry_tooltip(entry, value)
  tooltip_text = case value.to_s
    when 'ID de la Bateria' then 'Ingrese el ID de la batería'
    when 'Modelo' then 'Ingrese el modelo de la batería'
    when 'Serie' then 'Ingrese el número de serie de la batería'
    when 'Recepción' then "Formato (AAAA/MM/DD)\nEjemplo: 2024/11/31"
    when 'Factura' then 'Ingrese el número de factura'
    when 'Fecha Factura' then "Formato (AAAA/MM/DD)\nEjemplo: 2024/11/31"
    when 'Nota de Credito' then 'Ingrese el número de Nota de Crédito'
    when 'Fecha N.C' then "Formato (AAAA/MM/DD)\nEjemplo: 2024/11/31"
    when 'Motivo de la devolución' then "Ingrese el motivo de devolución (Estados permitidos:\n- Funcional (Devuelta pero sigue funcional)\n- Defectuoso\n- Cambio de modelo\n- Problema de fábrica\n- Daño en el envío\n- Incompatible"
    when 'Cliente' then "Ingrese el nombre del Cliente\n(al menos Nombre y Apellido y/o Nombre de la empresa)"
    when 'Vendedor' then "Ingrese el nombre del Vendedor\n(al menos Nombre y Apellido y/o Nombre de la empresa)"
    when 'Recarga' then "Ingrese el estado de recarga\n- Cargado\n- Descargado\n- En revisión\n- Defectuoso"
    when 'Fecha Envío' then 'Ingrese la fecha de envío (AAAA/MM/DD)'
    when 'Destino' then 'Ingrese el lugar de destino de la batería'
    when 'Comentarios' then 'Ingrese/edite comentario o informacion adicional de la bateria'
    else ''
  end
  entry.set_tooltip_text(tooltip_text)
end
