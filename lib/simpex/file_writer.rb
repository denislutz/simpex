class ImpexResult 

  def initialize(dest_folder)
    @dest_folder = dest_folder
  end

  def FileWriter.write(tables, dest_folder, params={})
    if params.empty? || params[:dest_folder].nil?
      dir_name = "tmp"
      unless Dir.exist?(dir_name)
        FileUtils.mkdir(dir_name)
      end
      destination = File.new("tmp") 
    else
      raise "the given destination is not an existing file or directory, create the file before" if (!params[:dest_folder].kind_of?(File) || !File.exist?(params[:dest_folder]))
      destination = params[:dest]
    end

    File.open(file_name, 'w') do |f|
      f.puts(@macros)
      f.puts("INSERT_UPDATE #{@name};" + @attributes.join(";"))
      @entries.each do |entry|
        f.puts entry.to_impex
      end
    end
  end 
end
