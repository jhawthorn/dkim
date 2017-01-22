require 'mail/dkim_field'

unless Mail::Field::FIELDS_MAP.has_key?(Mail::DkimField::FIELD_NAME)
  Mail::Field::FIELDS_MAP[Mail::DkimField::FIELD_NAME] = Mail::DkimField
  Mail::Field::STRUCTURED_FIELDS << Mail::DkimField::FIELD_NAME
  if defined?(Mail::Field::FIELD_ORDER_LOOKUP)
    Mail::Field::FIELD_ORDER_LOOKUP[Mail::DkimField::FIELD_NAME] = 8
  end
end