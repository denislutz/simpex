require File.expand_path('type.rb', 'src')
require File.expand_path('type_entry.rb', 'src')

namespace :simpex do
  @output_directory = "tmp/impex"

  #rake simpex:generate
  desc "Generates ImpEx file"
  task :generate do
    @category_macros = "$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']"
    @product_macros  = "$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']\n" +
                       "$prices=europe1Prices[translator=de.hybris.platform.europe1.jalo.impex.Europe1PricesTranslator]\n" +
                       "$baseProduct=baseProduct(code, catalogVersion(catalog(id[default='NamicsProducts']), version[default='Staged']));;;;;;;;"

    category_cols = "code[unique=true];$catalogVersion;name[lang=de];name[lang=en];description[lang=de];description[lang=en];"
    category_type = Type.new("Category", category_cols, @category_macros)

    product_cols = ";code[unique=true];name[lang=en];name[lang=de];unit(code);$catalogVersion;description[lang=en];approvalStatus(code);supercategories(code)"
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

    puts "Files generated inside 'tmp/impex/'."
  end

end
