require 'date'
require_relative 'constants'
class ValidationError < StandardError
end
class DateSearchValidators
  def self.valid_date?(date)
    /\A\d{4}\/\d{2}\/\d{2}\z/.match?(date)
  end
  def self.validate_length(value, max_length = MAX_LONGITUD_GENERAL)
    unless value.is_a?(String) && value.length <= max_length
      raise ValidationError, :invalid_length
    end
  end
  def self.valid_combined_date?(value)
    /\A\d{4}\/\d{2}\/\d{2}\z/.match?(value)
  end
  def self.valid_sensible_combined_date?(value)
    return false unless valid_combined_date?(value)
    year, month, day = value.split('/').map(&:to_i)
    raise ValidationError, "El año debe estar entre 1800 y 2050" unless (1800..2050).include?(year)
    raise ValidationError, "El mes debe estar entre 1 y 12" unless (1..12).include?(month)
    max_days = Date.new(year, month, -1).day
    raise ValidationError, "El día no es válido para el mes y año dados" unless (1..max_days).include?(day)
    true
  end
end