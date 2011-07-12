require 'test/unit'
require File.expand_path('simpex.rb',  'lib')
require 'fileutils'

class TestType < Test::Unit::TestCase
  #
  #INSERT_UPDATE Category;code[unique=true];$catalogVersion;name[lang=de];name[lang=en];description[lang=de];description[lang=en];
  #;SampleCategory;SimpexProducts:Online;Testkategorie;Sample category;Dies ist eine Testkategorie;This is a sample category;
  # 
  #INSERT_UPDATE Product;code[unique=true];name[lang=en]; name[lang=de];unit(code);$catalogVersion; description[lang=en]; description[lang=de]; approvalStatus(code);supercategories(code)
  #;sampleproduct1;SampleProduct1;Testprodukt1;pieces;SimpexProducts:Online;"This is a sample product";"Dies ist ein Testprodukt";approved;SampleCategory
  #;sampleproduct2;SampleProduct2;Testprodukt2;pieces;SimpexProducts:Online;"This is another sample product";"Dies ist ein weiteres Testprodukt";approved;SampleCategory

  def setup
    macros = "$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']"

    @category_type = Type.new("Category", %w{code[unique=true] $catalogVersion name[lang=de] name[lang=en]}, macros)

    @product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)}, macros)
  end

  def test_validate_type_input_on_creation
    assert_raise ArgumentError do
      @category_type = Type.new("MyType", "wrong;string")
    end
  end

  def test_should_create_a_type
    assert_not_nil @category_type.attributes
    assert_not_nil @category_type.entries
    puts @category_type.inspect
  end

  def test_should_create_a_type_entry
    entry = TypeEntry.new(@product_type, {"code" => "333", "name" => "MyName"})
    @product_type << entry
    puts entry.inspect
  end

  def test_entry_should_reference_other_entries
    entry = TypeEntry.new(@product_type, {"code" => "333", "name" => "MyName"})
    @product_type << entry

    assert_equal "333", entry.get("code")
    assert_equal "MyName", entry.get("name")
  end

  def test_should_fail_if_wrong_values_given
    assert_raise ArgumentError do
      entry = TypeEntry.new(@product_type, "somewrong string")
    end
    assert_raise ArgumentError do
      entry = TypeEntry.new(nil, "somewrong string")
    end
  end

  def test_entry_should_accept_array_of_values_and_assign_them_to_columns_according_to_the_order
    entry = TypeEntry.new(@product_type, %w{555 myproduct555 meinproduct555 pieces SimpexProducts:Online SampleCategory})
    assert_equal "myproduct555", entry.get("name[lang=en]")
    assert_equal "meinproduct555", entry.get("name[lang=de]")
    assert_equal "SampleCategory", entry.get("supercategories(code)")
  end

  def test_entry_should_inforce_to_use_unique_attributes_if_needed_for_fuzzy_matching
    product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de]})
    entry = TypeEntry.new(product_type, %w{555 myproduct555 meinproduct555 })
    assert_raise ArgumentError do
      entry.get("name")
    end
  end

  def test_entry_should_match_fuzzy_attribute_names
    product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)})
    entry = TypeEntry.new(product_type, %w{555 myproduct555 meinproduct555 pieces SimpexProducts:Online SampleCategory})

    assert_equal "555", entry.get("code")
    assert_equal "pieces", entry.get("unit")
    assert_equal "SampleCategory", entry.get("supercategories")

    assert_raise ArgumentError do
      entry.get("supercat")
    end
  end

  def test_entry_should_match_fuzzy_attribute_names_to_real_attributes

    product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)})
    entry = TypeEntry.new(product_type, %w{555 myproduct555 meinproduct555 pieces SimpexProducts:Online SampleCategory})

    assert_equal "555", entry.code
    assert_equal "pieces", entry.unit
    assert_equal "SampleCategory", entry.supercategories

  end

  def test_should_write_the_impex_resupt_to_the_given_folder
    impex_dest_dir = "test/tmp"
    FileUtils.mkdir(impex_dest_dir) unless Dir.exist?(impex_dest_dir)

    result = standard_result(impex_dest_dir)
    result.impexify

    FileUtils.rm_rf(impex_dest_dir)
  end

  def test_should_write_the_result_in_one_file
    impex_dest_dir = "test/tmp"
    FileUtils.mkdir(impex_dest_dir) unless Dir.exist?(impex_dest_dir)
    result_file_path = "#{impex_dest_dir}/result.csv" 

    assert !File.exist?(result_file_path)
    result = standard_result(impex_dest_dir)
    result.impexify("result.csv")
    assert File.exist?(result_file_path), "the file #{result_file_path} should have been created"

    File.delete(result_file_path)
  end

  private 
  def standard_result(impex_dest_dir)

    result = ImpexResult.new(impex_dest_dir)

    language_type = Type.new("Language", %w{isocode[unique=true] active})
    language_type << TypeEntry.new(language_type, %w{de true})
    language_type << TypeEntry.new(language_type, %w{en true})
    result << language_type 

    catalog_type = Type.new("Catalog", %w{id[unique=true] name[lang=de] name[lang=en] defaultCatalog})
    catalog = TypeEntry.new(catalog_type, %w{simpex_catalog SimpexCatalog SimpexCatalog true})
    catalog_id = catalog.get("id[unique=true]")
    catalog_type << catalog
    result << catalog_type

    catalog_version_type = Type.new("CatalogVersion", %w{catalog(id)[unique=true] version[unique=true] active defaultCurrency(isocode)})
    catalog_version = TypeEntry.new(catalog_version_type, [catalog_id, "online", "true", "EUR", "de,en"])
    catalog_version_type << catalog_version
    result << catalog_version_type 

    result
  end
end
