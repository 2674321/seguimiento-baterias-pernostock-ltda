require 'date'
require_relative 'constants'
class ValidationError < StandardError
end
class DateSearchValidators
  def self.valid_date?(date)
    /\A\d{4}\/\d{2}\/\d{2}\z/.match?(date)
  end
  def self.validate_length(value, max_length = MAX_LONGITUD_GENERAL)
    raise ValidationError, :invalid_length unless value.is_a?(String) && value.length <= max_length
  rescue ValidationError => e
    show_error_message(:invalid_length, e.message)
  end
  def self.valid_combined_date?(value)
    /\A\d{4}\/\d{2}\/\d{2}\z/.match?(value)
  end
  def self.valid_sensible_combined_date?(value)
    return false unless valid_combined_date?(value)
    year, month, day = value.split('/').map(&:to_i)
    begin
      unless (1800..2050).include?(year)
        raise ValidationError, "El año debe estar entre 1800 y 2050"
      end
    rescue ValidationError => e
      show_error_message(:invalid_year_range, e.message)
      return false
    end
    begin
      unless (1..12).include?(month)
        raise ValidationError, "El mes debe estar entre 1 y 12"
      end
    rescue ValidationError => e
      show_error_message(:invalid_month_range, e.message)
      return false
    end
    begin
      max_days = Date.new(year, month, -1).day
      unless (1..max_days).include?(day)
        raise ValidationError, "El día no es válido para el mes y año dados"
      end
    rescue ValidationError => e
      show_error_message(:invalid_day, e.message)
      return false
    end
    true
  end
end
