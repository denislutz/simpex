require 'rubygems'
require 'csv'

class Type 
  attr_reader :attributes, :entries, :name, :macros, :impex_command
  attr_writer :impex_command

  def  initialize(name, type_attributes, macros=[])
    raise "Type name was not given, use e.g. 'Product'  or 'Category'" if name.empty?
    raise ArgumentError.new("Attribute values must be given in an array, use '%w{code name description catalog}'") unless type_attributes.kind_of?(Array)
    if macros.kind_of? String
      @macros = [macros]
    else
      @macros = macros
    end
    @attributes = []
    type_attributes.each do |attribute|
      next if attribute.nil? || attribute.empty?
      if attribute.kind_of?(Hash)
        @attributes += resolve_to_attributes(attribute)
      else
        @attributes << attribute
        if attribute =~ /^\$/
          if @macros.empty? || @macros.none?{|m| m.split("=").first == attribute}
            raise ArgumentError.new "You are using a macro that is not defined: #{attribute}, declared macros are #{@macros}" 
          end
        end
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
    return result if @entries.empty?
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

  def unregister_by(attribute, value)
    self.entries.reject!{|entry| entry.send(attribute) == value}
  end

  def find_by(attribute, value)
    self.entries.find_all{|entry| entry.send(attribute) == value}
  end

  private
  def resolve_to_attributes(attrib)
    raise "The feature of reading hashes of attrbite names is planned but not implemented yet, implement it here"
  end

  def impexify(array)
    CSV.generate_line([nil] + array + [nil], :col_sep => ";")
  end

end

