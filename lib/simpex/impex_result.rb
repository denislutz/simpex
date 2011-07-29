class ImpexResult 
  def initialize(dest_folder)
    raise "No existing destination folder was given, make sure it exists" if dest_folder.nil? || !Dir.exist?(dest_folder)
    @dest_folder = dest_folder
    @types = []
  end

  def <<(type)
    @types << type
  end

  def impexify(result_file_name="")
    if result_file_name.empty?
      @types.each_with_index do |type, index|
        file_name = "#{@dest_folder}/#{format_number(index)}_#{type.name.downcase}.csv"
        File.open(file_name, 'w') do |f|
          f.puts(type.to_imp)
        end
      end
    else
      result_file_name = File.basename(result_file_name)
      file_name = "#{@dest_folder}/#{result_file_name}"
      puts "writing complete result to the file #{file_name}"
      result_file_name = File.basename(result_file_name)
      raise "You gave the directory #{result_file_name} instead of a single file" if File.directory?(result_file_name)
      File.open(file_name, "w") do |f|
        all_macros = []
        @types.each do |type|
          type.macros.each do |macro|
            all_macros << macro unless all_macros.include?(macro)
          end
        end
        all_macros.each do |m|
          f.puts m
        end
        f.puts "\n"
        @types.each do |type|
          f.puts(type.to_imp(false))
        end
      end
    end
  end 

  def format_number(number_to_format, numeric_positions="4")
    "%0#{numeric_positions}d" % number_to_format
  end
end
