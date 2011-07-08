require File.expand_path('simpex.rb', 'lib')
require 'rake/testtask'

require 'rubygems'
require 'rest-client'

namespace :simpex do
  @output_directory = "tmp"

  #rake simpex:generate
  desc "Generates ImpEx file"
  task :generate do
    @category_macros = "$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']"
    @product_macros  = "$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']\n" +
      "$prices=europe1Prices[translator=de.hybris.platform.europe1.jalo.impex.Europe1PricesTranslator]\n" +
      "$baseProduct=baseProduct(code, catalogVersion(catalog(id[default='SimpexProducts']), version[default='Staged']));;;;;;;;"

    category_cols = %w{code[unique=true] $catalogVersion name[lang=de] name[lang=en] description[lang=de] description[lang=en]}
    category_type = Type.new("Category", category_cols, @category_macros)

    product_cols = %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion description[lang=en] approvalStatus(code) supercategories(code)}
    product_type = Type.new("Product", product_cols, @product_macros)

    categories_names = %w{cat1 cat2 cat3}
    categories_names.each_with_index do |name, index|
      category_type << TypeEntry.new(category_type, {"code" => "333", "name" => "MyCatName"})
    end

    main_category = category_type.entries.first

    product_names = %w{prod1 prod2 prod3}
    product_names.each_with_index do |name, index|
      product = TypeEntry.new(product_type, {"code" => "333", "name" => "MyProdName"})
      product.set("supercategories" => main_category.get("code"))
    end

    category_type.to_impex("#{@output_directory}/001_category.csv")
    product_type.to_impex("#{@output_directory}/002_product.csv")

    puts "Files generated inside #{@output_directory}"
  end

  desc "Run all tests"
  Rake::TestTask.new("test") do |t|
    t.pattern = 'test/test_*.rb'
    t.verbose = true
    t.warning = true
  end 

  desc "Does a test by posting an impex file to a local hybris server"
  task :validate do
    impex = %w{ 
      INSERT_UPDATE Language;isocode[unique=true];active;
      ;de;true;
      ;en;true;
    }
    RestClient.post("http://localhost:9001/admin/admin_impex_import.jsp", :upload => File.new("tmp/001_category.csv"))
  end

end
