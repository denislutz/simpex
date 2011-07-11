require 'rubygems'
require 'csv'

class Type 
  attr_reader :attributes, :entries, :name

  def  initialize(name, type_attributes, macros="")
    raise "Type name was not given, use e.g. 'Product'  or 'Category'" if name.empty?
    raise ArgumentError.new("Attribute values must be given in an array, use '%w{code name description catalog}'") unless type_attributes.kind_of?(Array)
    @macros = macros
    @attributes = type_attributes.reject{|e| e == ""} # Array of instance vars
    @name = name 
    @entries = []
    @impex_command = "INSERT_UPDATE"
  end

  def <<(entry)
    @entries << entry
  end

  def to_imp
    puts "impexifying #{self.inspect}"
    result = ""
    unless @macros.empty?
      result << @macros
      result << "\n" 
    end
    result << "#{@impex_command} #{@name}" +  impexify(@attributes)
    @entries.each do |entry|
      result << entry.to_imp
    end
    result << "\n" 
    result
  end

  private
  def impexify(array)
    CSV.generate_line([nil] + array + [nil], :col_sep => ";")
  end

end

