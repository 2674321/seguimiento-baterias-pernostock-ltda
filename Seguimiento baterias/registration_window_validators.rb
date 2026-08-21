def valid_motivo?(value)
 allowed_states = ["funcional","Funcional", "defectuoso", "Defectuoso", "problema de fábrica", "Problema de fábrica", "daño en envio","Daño en envio", "Daño en envío", "daño en envío", "Incompatible", "incompatible", "Error en el pedido", "error en el pedido", "Cambio de modelo", "cambio de modelo"]
  normalized_value = value.to_s.downcase.strip
  allowed_states.any? { |state| normalized_value.include?(state) } &&
    normalized_value.split.all? { |part| !part.empty? && part.match?(/\A[a-zA-Z]+\z/) }
end
def valid_espacios_en_blanco?(input)
  return false if input.count(' ') > 3
  true
end
def valid_cliente?(value)
  parts = value.split
  parts.length >= 1 && parts.all? { |part| !part.empty? && part.match?(/\A[^0-9!@#$%^&*()_+={}\[\]|\\:;"'<>,.?\/]+\z/) }
end
def valid_vendedor?(value)
  parts = value.split
  parts.length >= 1 && parts.all? { |part| !part.empty? && part.match?(/\A[^0-9!@#$%^&*()_+={}\[\]|\\:;"'<>,.?\/]+\z/) }
end
def valid_recarga?(value, allowed_values)
  normalized_value = value.to_s.downcase.strip
  normalized_allowed_values = allowed_values.map { |v| v.to_s.downcase.strip }
  normalized_value.empty? || normalized_allowed_values.include?(normalized_value)
end
def required_fields_valid?(column_entries, required_fields)
  required_fields.all? { |field| !column_entries[field.to_sym].text.empty? }
end
def valid_combined_date?(date_text)
  /\A\s*\d{4}\/\d{2}\/\d{2}\s*\z/ === date_text
end
def valid_sensible_combined_date?(value)
  return false unless valid_combined_date?(value)
  date_parts = value.split('/')
  return false unless date_parts.length == 3
  year, month, day = date_parts.map(&:to_i)
  return false unless (1950..2050).include?(year)
  return false unless (1..12).include?(month)
  max_days = Date.new(year, month, -1).day
  return false unless (1..max_days).include?(day)
  true
end
def validate_length(value, max_length = MAX_LONGITUD_GENERAL)
  raise ValidationError, "String length exceeds the maximum allowed (#{max_length} characters)" unless value.is_a?(String) && value.length <= max_length
end
def validate_nota_de_credito?(input)
  Float(input) && Integer(input)
  true
rescue ArgumentError, TypeError
  false
end
def valid_destino?(value)
  !value.nil? && value.match?(/\A[\p{L}'\-\s,\/]+\z/)
end
def valid_modelo?(value)
  !value.nil? && value.match?(/\A[\p{L}0-9\/]+\z/)
end
def valid_serie?(value)
  !value.nil? && value.match?(/\A[\p{L}0-9\/]+\z/)
end
def valid_factura?(value)
  !value.nil? && value.match?(/\A[\p{L}0-9\/]+\z/)
end
