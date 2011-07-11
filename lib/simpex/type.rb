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

  def to_impex(file_name="")
    if file_name.empty? 
      file_name = "#{@name}.csv"
    else
      dir_name = File.dirname(file_name)
      unless Dir.exist?(dir_name)
        FileUtils.mkdir(dir_name)
      end
    end
    puts "writing impex file #{file_name}"
    File.open(file_name, 'w') do |f|
      f.puts(@macros)
      f.puts("INSERT_UPDATE #{@name};" + @attributes.join(";"))
      @entries.each do |entry|
        f.puts entry.to_impex
      end
    end
  end

  def to_imp
    puts "impexifying #{self.inspect}"
    result = ""
    result << @macros
    result << "\n" 
    result << "\n" 
    result << "#{@impex_command} #{@name}" +  impexify(@attributes)
    result << "\n" 
    @entries.each do |entry|
      result << entry.to_imp
    end
    result
  end

  private
  def impexify(array)
    CSV.generate_line([nil] + array + [nil], :col_sep => ";")
  end

end

