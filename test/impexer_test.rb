require 'test/unit'
require '../src/type'
require '../src/type_entry'
require '../src/impex_file'

class TestRubyImpexer < Test::Unit::TestCase
  #
  # Macro definitions (1)
  #
  #$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']
  #$prices=europe1Prices[translator=de.hybris.platform.europe1.jalo.impex.Europe1PricesTranslator]
  #$baseProduct=baseProduct(code, catalogVersion(catalog(id[default='NamicsProducts']), version[default='Staged']));;;;;;;;
  #
  # Create a category (2)
  #
  #INSERT_UPDATE Category;code[unique=true];$catalogVersion;name[lang=de];name[lang=en];description[lang=de];description[lang=en];
  #;SampleCategory;NamicsProducts:Online;Testkategorie;Sample category;Dies ist eine Testkategorie;This is a sample category;
  # 
  #
  # Create some products (3)
  #
  #INSERT_UPDATE Product;code[unique=true];name[lang=en]; name[lang=de];unit(code);$catalogVersion; description[lang=en]; description[lang=de]; approvalStatus(code);supercategories(code)
  #;sampleproduct1;SampleProduct1;Testprodukt1;pieces;NamicsProducts:Online;"This is a sample product";"Dies ist ein Testprodukt";approved;SampleCategory
  #;sampleproduct2;SampleProduct2;Testprodukt2;pieces;NamicsProducts:Online;"This is another sample product";"Dies ist ein weiteres Testprodukt";approved;SampleCategory
  #;sampleproduct3;SampleProduct3;Testprodukt3;pieces;NamicsProducts:Online;"This is the third sample product";"Dies ist das dritte Testprodukt";approved;SampleCategory

  def setup
@category_macros = <<EOS
$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']
EOS

@produc_macros = <<EOS
$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']
$prices=europe1Prices[translator=de.hybris.platform.europe1.jalo.impex.Europe1PricesTranslator]
$baseProduct=baseProduct(code, catalogVersion(catalog(id[default='NamicsProducts']), version[default='Staged']));;;;;;;;
EOS
  end

  #main test
  def test_should_generate_impex
    category_cols = "code[unique=true];$catalogVersion;name[lang=de];name[lang=en];description[lang=de];description[lang=en];"
    category_type = Type.new("Category", category_cols, @category_macros)

    product_cols = ";code[unique=true];name[lang=en];name[lang=de];unit(code);$catalogVersion;description[lang=en];approvalStatus(code);supercategories(code)"
    product_type = Type.new("Product", product_cols, @produc_macros)

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

    category_type.to_impex("generated_impex/001_category.csv")
    product_type.to_impex("generated_impex/002_product.csv")
  end

  #single tests
  #
  def test_should_create_a_type 
    category_cols = "code[unique=true];$catalogVersion;name[lang=de];name[lang=en];description[lang=de];description[lang=en];" 
    category_type = Type.new("Category", category_cols, @category_macros)
    
    assert_not_nil category_type.attributes
    assert_not_nil category_type.entries
    puts category_type.inspect
  end
  def test_should_create_a_type_entry 
    product_cols = ";code[unique=true];name[lang=en];name[lang=de];unit(code);$catalogVersion;description[lang=en];approvalStatus(code);supercategories(code)"
    product_type = Type.new("Product", product_cols, @produc_macros)
    
    entry = TypeEntry.new(product_type, {"code" => "333", "name" => "MyName"})
    product_type << entry
    puts entry.inspect
  end
  def test_entry_should_reference_other_entries 
    product_cols = ";code;name;name[lang=de];unit(code);$catalogVersion;description[lang=en];approvalStatus(code);supercategories(code)"
    product_type = Type.new("Product", product_cols, @produc_macros)
    
    entry = TypeEntry.new(product_type, {"code" => "333", "name" => "MyName"})
    product_type << entry

    assert_equal "333", entry.get("code")
    assert_equal "MyName", entry.get("name")
  end
end
