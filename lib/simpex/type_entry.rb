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

  def get(attribute_name)
    attr_names = @values.keys
    if attr_names.include?(attribute_name)
      @values[attribute_name]
    else
      guessed_attribute = attr_names.find{|e| e.split("(").first == attribute_name || e.split("[").first == attribute_name}
      if guessed_attribute
        @values[guessed_attribute]
      else
        raise ArgumentError.new "No attribte '#{attribute_name}' was found for the type entry, declared attributes: #{attr_names.inspect}"
      end
    end
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
