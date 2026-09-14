def validate_date_selection(start_date_entry, end_date_entry, date_button_in_window)
  if dates_selected?(start_date_entry, end_date_entry)
    if dates_valid?(start_date_entry, end_date_entry)
      date_button_in_window.set_label('Criterio activo')
    else
      show_message('Por favor, ingrese fechas válidas en formato AAAA/MM/DD en ambos campos')
    end
  else
    show_message('Por favor, seleccione fechas antes de validar.')
  end
end
def dates_selected?(start_entry, end_entry)
  start_date = start_entry.text.strip
  end_date = end_entry.text.strip
  return !start_date.empty? && !end_date.empty?
end
def dates_valid?(start_entry, end_entry)
  start_date = start_entry.text.strip
  end_date = end_entry.text.strip
  return !start_date.empty? && !end_date.empty?
end
