require_relative 'field_validators'
def valid_motivo?(value)
  FieldValidators.valid_motivo?(value)
end
def valid_cliente?(value)
  FieldValidators.valid_client_or_vendor?(value)
end
def valid_vendedor?(value)
  FieldValidators.valid_client_or_vendor?(value)
end
def valid_recarga?(value, allowed_values)
  FieldValidators.valid_recarga?(value, allowed_values)
end
def required_fields_valid?(column_entries, required_fields)
  required_fields.all? { |field| !column_entries[field.to_sym].text.empty? }
end
def valid_combined_date?(date_text)
  FieldValidators.valid_date_format?(date_text)
end
def valid_sensible_combined_date?(value)
  FieldValidators.valid_sensible_date?(value)
end
def validate_nota_de_credito?(input)
  FieldValidators.valid_positive_integer_list?(input)
end
def valid_destino?(value)
  FieldValidators.valid_destino?(value)
end
def valid_modelo?(value)
  FieldValidators.valid_string_only?(value)
end
def valid_serie?(value)
  FieldValidators.valid_string_only?(value)
end
def valid_factura?(value)
  FieldValidators.valid_string_only?(value)
end