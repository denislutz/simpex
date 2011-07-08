require 'rubygems'
require 'fastercsv'

class Type 
  attr_reader :attributes, :entries

  def  initialize(name, header, macros="")
    @macros = macros
    @attributes = header.split(";").reject{|e| e == ""} # Array of instance vars
    @name = name 
    @entries = []
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

  private
  def impexify(array)
    FasterCSV.generate_line([nil] + array + [nil], :col_sep => ";")
  end
  
end

