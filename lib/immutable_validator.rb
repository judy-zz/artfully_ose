class ImmutableValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    if (record.send("#{attribute}_changed?") && !record.new_record?)
      record.errors[attribute] << (options[:message] || "#{attribute} cannot be changed") 
    end
  end
end