class ImpexResult 
  def initialize(dest_folder)
    raise "No existing destination folder was given, make sure it exists" if dest_folder.nil? || !Dir.exist?(dest_folder)
    @dest_folder = dest_folder
    @tables = []
  end

  def <<(type)
    @tables << type
  end

  def impexify
    @tables.each_with_index do |table, index|
      file_name = "#{@dest_folder}/#{format_number(index)}_#{table.name.downcase}.csv"
      File.open(file_name, 'w') do |f|
        f.puts(table.to_imp)
      end
    end
  end 


  def format_number(number_to_format, numeric_positions="4")
    "%0#{numeric_positions}d" % number_to_format
  end
end
