require 'csv'

class TypeEntry

  attr :type, :values

  def  initialize(type, values)
    raise ArgumentError.new("Type must be a Type") unless type.kind_of? Type
    raise ArgumentError.new("Values must be a hash or an array") if (!values.kind_of?(Hash) ) && !values.kind_of?(Array)

    @type = type

    @values = @type.attributes.inject({}) do |result, att|
      result[att] = nil
      result
    end 

    if values.kind_of?(Hash)
      values.each do |key, value|
        real_att_name = guess_attribute(key)
        if real_att_name
          set(real_att_name, value)
        end
      end
    else 
      if @type.attributes.size < values.size
        raise ArgumentError.new "The number of values for the type entry are more (#{values.size}) then defined (#{@type.attributes.size}), inside the type '#{type.name}' following attributes are expected #{type.attributes.inspect}" 
      end
      if @type.attributes.size > values.size
        raise ArgumentError.new "The number of values for the type entry are less (#{values.size}) then defined (#{@type.attributes.size}), inside the type '#{type.name}' following attributes are expected #{type.attributes.inspect}" 
      end
      @type.attributes.each_with_index do |att,index|
        set(att, values[index])
      end
    end
    type << self
  end

  def get(att_name)
    attr_names = @values.keys
    if attr_names.include?(att_name)
      @values[att_name]
    else
      @values[guess_attribute(att_name)]
    end
  end

  def method_missing(id, *args)
    self.get("#{id}")
  end

  def set(attributes)
    @values.merge!(attributes)
  end

  def set(key, value)
    if value.kind_of?(Array)
      @values[key] = value.reject{|v| v.nil?}.join(",")
    else
      @values[key] = value
    end
  end

  def to_imp
    impexify(@values.values)
  end

  def cat_ver_specific(attr_name)
    self.get(attr_name) + ":" + self.get("catalogVersion")
  end
  
  private
  def guess_attribute(att_name)
    attr_names = @values.keys
    guessed_attribute_matches = attr_names.select{|e| e.split("(").first == att_name || 
                                                      e.split("[").first == att_name || 
                                                      e.split("$").last == att_name }

    if guessed_attribute_matches.size > 1
      error_msg = "There is more than one matching attribute name for the given 
                        name #{att_name}, matches are #{guessed_attribute_matches.inspect}, 
                      using of full attribute names is advised"
                      raise ArgumentError.new error_msg
    else
      guessed_attribute = guessed_attribute_matches.first
      if guessed_attribute
        guessed_attribute
      else
        raise ArgumentError.new "No attribte '#{att_name}' was found for the type '#{self.type.name}', declared attributes: #{attr_names.inspect}"
      end
    end
  end

  def impexify(array)
    CSV.generate_line([nil] + array + [nil], :col_sep => ";")
  end
end
