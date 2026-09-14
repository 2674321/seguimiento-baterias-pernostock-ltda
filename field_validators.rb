require 'date'
module FieldValidators
  MIN_YEAR = 1950
  MAX_YEAR = 2050
  MAX_COMMENT_LENGTH = 255

  MOTIVO_STATES = [
    "funcional", "Funcional", "defectuoso", "Defectuoso",
    "problema de fábrica", "Problema de fábrica", "daño en envio", "Daño en envio",
    "Daño en envío", "daño en envío", "Incompatible", "incompatible",
    "Error en el pedido", "error en el pedido", "Cambio de modelo", "cambio de modelo"
  ].freeze

  RECARGA_STATES = [
    "cargado", "descargado", "en revision", "defectuoso",
    "Cargado", "Descargado", "En revision", "Defectuoso", "En revisión"
  ].freeze

  module_function

  def valid_motivo?(value)
    normalized_value = value.to_s.downcase.strip
    MOTIVO_STATES.any? { |state| normalized_value.include?(state) } &&
      normalized_value.split.all? { |part| !part.empty? && part.match?(/\A[a-zA-Z]+\z/) }
  end

  def valid_client_or_vendor?(value)
    parts = value.split
    parts.length >= 1 && parts.all? { |part| !part.empty? && part.match?(/\A[^0-9!@#$%^&*()_+={}\[\]|\\:;"'<>,.?\/]+\z/) }
  end

  def valid_recarga?(value, allowed_values)
    normalized_value = value.to_s.downcase.strip
    normalized_allowed_values = allowed_values.map { |v| v.to_s.downcase.strip }
    normalized_value.empty? || normalized_allowed_values.include?(normalized_value)
  end

  def valid_date_format?(date_text)
    /\A\s*\d{4}\/\d{2}\/\d{2}\s*\z/ === date_text
  end

  def valid_sensible_date?(value)
    return false unless valid_date_format?(value)
    date_parts = value.split('/')
    return false unless date_parts.length == 3
    year, month, day = date_parts.map(&:to_i)
    return false unless (MIN_YEAR..MAX_YEAR).include?(year)
    return false unless (1..12).include?(month)
    max_days = Date.new(year, month, -1).day
    return false unless (1..max_days).include?(day)
    true
  end

  def valid_positive_integer_list?(input)
    Float(input)
    Integer(input)
    true
  rescue ArgumentError, TypeError
    false
  end

  def valid_edit_positive_integers?(value)
    value =~ /^\d+(\s\d+)*$/
  end

  def valid_destino?(value)
    !value.nil? && value.match?(/\A[\p{L}'\-\s,\/]+\z/)
  end

  def valid_string_only?(value)
    !value.nil? && value.match?(/\A[\p{L}0-9\/]+\z/)
  end

  def valid_simple_text?(value)
    value =~ /^[A-Za-z0-9\s,\-\/]+$/
  end

  def valid_comment?(value)
    return true if value.length <= MAX_COMMENT_LENGTH && value !~ /\A\d+\z/
    false
  end
end