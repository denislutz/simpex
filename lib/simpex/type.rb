require 'rubygems'
require 'csv'

class Type 
  attr_reader :attributes, :entries, :name, :macros, :impex_command, :impex_result, :after_each
  attr_writer :impex_command, :impex_result, :memory_safe, :after_each

  def  initialize(name, type_attributes, macros=[])
    raise "Type name was not given, use e.g. 'Product'  or 'Category'" if name.empty?
    raise ArgumentError.new("Attribute values must be given in an array, use '%w{code name description catalog}'") unless type_attributes.kind_of?(Array)
    raise "Macros was given but is nil" if macros.nil?

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
          if @macros.empty?
            raise ArgumentError.new "In the type '#{name}', you are using a macro but no macros are given at all, pass the macros as an array to the type constructor." 
          end
          if @macros.none?{|m| m.split("=").first == attribute.split("[").first}
            raise ArgumentError.new "In the type #{name}, you are using a macro that is not defined: #{attribute}, declared macros are #{@macros.inspect}" 
          end
        end
      end
    end
    @name = name 
    @entries = []
    @impex_command = "INSERT_UPDATE"
    @impex_result = nil
    @memory_safe = false
    @after_each = []
    @before_each = []
  end

  def <<(entry)
    @entries << entry
    if @impex_result 
      @impex_result.add_entries_number(1)
    elsif @memory_safe
      raise "impex result object is not set, but we are running in a memory safe impex generation"
    end
  end

  def empty?
    self.entries.empty?
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
    unless after_each.empty?
      result << "\"#%afterEach:\n" 
      after_each.each do |bash_line|
        result << bash_line << "\n"
      end
      result << "\"\n" 
    end
    @entries.each do |entry|
      result << entry.to_imp
    end
    result << "\n" 
    unless after_each.empty?
      result << "\"#%afterEach:end\"" 
    end
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

