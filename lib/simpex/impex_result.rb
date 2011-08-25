class ImpexResult 

  attr_writer :memory_safe, :max_type_entries_in_tree

  def initialize(dest_folder)
    raise "Given dest folder #{dest_folder} is either nil or does not exist!" if dest_folder.nil? || !Dir.exist?(dest_folder)
    @dest_folder = dest_folder
    @types = []
    @max_type_entries_in_tree = 2000 
    @global_enties_number = 0
    @impexify_occurences = 0
    @memory_safe = false
  end

  def <<(type)
    @types << type
    if @memory_safe
      type.memory_safe = true
    end
    type.impex_result = self
    raise "no result set on type" unless type.impex_result 
    add_entries_number(type.entries.size)
    check_for_impexify
  end

  def impexify(result_file_name="", time_stampify = true)
    if result_file_name.empty?
      stamp = Time.now.strftime("%S_%M_%H_%d_%m_%Y") if time_stampify
      @types.each_with_index do |type, index|
        if time_stampify
          file_name = "#{@dest_folder}/#{format_number(@impexify_occurences)}_#{type.name.downcase}_#{stamp}.csv"
        else
          file_name = "#{@dest_folder}/#{format_number(@impexify_occurences)}_#{type.name.downcase}.csv"
        end
        unless type.empty?
          puts "writing #{type.name} to #{file_name}"
          File.open(file_name, 'w') do |f|
            f.puts type.to_imp 
          end
          @impexify_occurences += 1
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
          f.puts type.to_imp(false) unless type.empty?
        end
      end
      @impexify_occurences += 1
    end
    clean_all_type_entries
  end 

  def format_number(number_to_format, numeric_positions="4")
    "%0#{numeric_positions}d" % number_to_format
  end

  def global_enties_number 
    @global_enties_number
  end

  def add_entries_number(added_number)
    @global_enties_number +=added_number
    check_for_impexify 
  end

  private
  def clean_all_type_entries
    @types.each do |type|
      type.entries.clear
    end
    @global_enties_number = 0
  end
  def check_for_impexify
    if @memory_safe
      if  @global_enties_number > @max_type_entries_in_tree
        puts "impexifying all entries since global entries #{@global_enties_number} is bigger then max #{@max_type_entries_in_tree}"
        self.impexify 
      end
    end
  end
end

