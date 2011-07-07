class TypeEntry

  attr :type, :values

  def  initialize(type, values)
    raise "Type must be a Type" unless type.kind_of? Type
    raise "Values must be a hash" if (!values.kind_of?(Hash) )
    @type = type
    @values = values 
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
end
