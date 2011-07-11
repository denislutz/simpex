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
      file_name = "#{@dest_folder}/#{index}_#{table.name.downcase}.csv"
      File.open(file_name, 'w') do |f|
        f.puts(table.to_imp)
      end
    end
  end 
end
