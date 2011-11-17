require "bundler/gem_tasks"
require 'rake/testtask'
require File.expand_path('simpex.rb', 'lib')

require 'rubygems'

namespace :simpex do
  desc "Generates ImpEx file"
  task :generate do
    output_directory = "tmp"
    Factory.generate_base_catalog_setup_to(output_directory)
    Factory.generate_base_catalog_setup_to_file(output_directory,"single_file_result.csv")
    puts "Files generated inside #{output_directory}"
  end

  desc "Run all tests"
  Rake::TestTask.new("test") do |t|
    t.pattern = 'test/test_*.rb'
    t.verbose = true
    t.warning = true
  end 
end
