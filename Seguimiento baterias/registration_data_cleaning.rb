def limpiar_datos(column_entries, comment_entry)
  cleaned_data = {}
  column_entries.each do |key, entry|
    cleaned_entry = limpiar_entrada(entry.text)
    cleaned_data[key] = cleaned_entry unless cleaned_entry.nil?
  end
  cleaned_comment = limpiar_entrada(comment_entry.text)
  cleaned_data[:COMENTARIOS] = cleaned_comment unless cleaned_comment.nil?
  cleaned_data
end
def limpiar_entrada(texto)
  cleaned_text = texto.strip
  cleaned_text = cleaned_text.split.join(' ')
  cleaned_text.empty? ? nil : cleaned_text
end
def redefine_datos_originales(column_entries, comment_entry)
  datos_a_insertar = {}
  column_entries.each do |key, entry|
    validate_length(entry.text)
    datos_a_insertar[key] = entry.text
  end
  validate_length(comment_entry.text)
  datos_a_insertar[:COMENTARIOS] = comment_entry.text
  datos_a_insertar
end
