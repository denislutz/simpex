require 'csv'
class TypeEntry

  attr :type, :values

  def  initialize(type, values)
    raise ArgumentError.new("Type must be a Type") unless type.kind_of? Type
    raise ArgumentError.new("Values must be a hash or an array") if (!values.kind_of?(Hash) ) && !values.kind_of?(Array)
    @type = type

    if values.kind_of?(Hash)
      @values = values 
    else 
      @values = {}
      @type.attributes.each_with_index do |att,index|
        @values[att] = values[index]
      end
    end
  end

  def get(attribute)
    @values[attribute]
  end

  def set(attributes)
    @values.merge!(attributes)
  end

  def to_impex
    @values.values.join(";")
  end

  def to_imp
    impexify(@values.values)
  end

  private
  def impexify(array)
    CSV.generate_line([nil] + array + [nil], :col_sep => ";")
  end
end
