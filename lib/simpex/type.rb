require 'rubygems'
require 'csv'

class Type 
  attr_reader :attributes, :entries, :name, :macros

  def  initialize(name, type_attributes, macros=[])
    raise "Type name was not given, use e.g. 'Product'  or 'Category'" if name.empty?
    raise ArgumentError.new("Attribute values must be given in an array, use '%w{code name description catalog}'") unless type_attributes.kind_of?(Array)
    @macros = macros
    @attributes = []
    type_attributes.each do |attribute|
      next if attribute.nil? || attribute.empty?
      if attribute.kind_of?(Hash)
        @attributes += resolve_to_attributes(attribute)
      else
        @attributes << attribute
      end
    end
    @name = name 
    @entries = []
    @impex_command = "INSERT_UPDATE"
  end

  def <<(entry)
    @entries << entry
  end

  def to_imp(macros=true)
    result = ""
    if (!@macros.empty? && macros)
      @macros.each do |macro|
        result << macro 
        result << "\n" 
      end
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

  def resolve_to_attributes(attrib)
    raise "The feature of reading hashes of attrbite names is planned but not implemented yet, implement it here"
  end

  def impexify(array)
    CSV.generate_line([nil] + array + [nil], :col_sep => ";")
  end

end

