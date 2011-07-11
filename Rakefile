require File.expand_path('simpex.rb', 'lib')
require 'rake/testtask'

require 'rubygems'
require 'rest-client'

namespace :simpex do

  desc "Generates ImpEx file"
  task :generate do
    output_directory = "tmp"
    Factory.generate_base_catalog_setup output_directory
    puts "Files generated inside #{output_directory}"
  end

  desc "Run all tests"
  Rake::TestTask.new("test") do |t|
    t.pattern = 'test/test_*.rb'
    t.verbose = true
    t.warning = true
  end 

  desc "TODO: Does a test by posting an impex file to a local hybris server"
  task :validate do
    impex = %w{ 
      INSERT_UPDATE Language;isocode[unique=true];active;
      ;de;true;
      ;en;true;
    }
    RestClient.post("http://localhost:9001/admin/admin_impex_import.jsp", :upload => File.new("tmp/001_category.csv"))
  end

end
