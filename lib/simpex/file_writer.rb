def FileWriter
  def write(tables, params={})
    if params.empty?
      destination = File.new("result.csv") 
    else
      destination = params[:dest]
    end
    # write to single files if a folder or no destination is given
    # write to the destination file if its given
  end 
end
