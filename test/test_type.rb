require 'test/unit'
require File.expand_path('simpex.rb',  'lib')
require 'fileutils'

class TestType < Test::Unit::TestCase
  def setup
    @macros = "$catalogVersion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']"

    @category_type = Type.new("Category", %w{code[unique=true] $catalogVersion name[lang=de] name[lang=en]}, @macros)

    @product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)}, @macros)
  end

  def test_validate_type_input_on_creation
    assert_raise ArgumentError do
      @category_type = Type.new("MyType", "wrong;string")
    end
  end

  def test_should_have_setter_getter_for_impex_command
    assert_equal "INSERT_UPDATE", @product_type.impex_command
    @product_type.impex_command = "update"
    assert_equal "update", @product_type.impex_command
  end

  def test_should_create_a_type
    assert_not_nil @category_type.attributes
    assert_not_nil @category_type.entries
    puts @category_type.inspect
  end

  def test_type_should_validate_the_presence_of_macros
    assert_raises ArgumentError do
      Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)})
    end

    macros = ["$catalogVersion=adsfasdfasdf"]
    Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)}, macros)
  end

  def test_shoud_add_an_after_each_statement
      bash_script = "#%afterEach: "
      after_each = "impex.getLastImportedItem().setApprovalStatus(impex.getLastImportedItem().getBaseProduct().getApprovalStatus());" 
      product_type = Type.new("Product", %w{code[unique=true] name[lang=en]})
      TypeEntry.new(product_type,%w{ 666 denis})
      product_type.after_each << after_each
      assert_match /impex/, product_type.after_each.first
      assert_match /#%afterEach/, product_type.to_imp
      puts product_type.to_imp
  end

  def test_type_should_generate_nothing_if_no_entries
    assert_equal "", @product_type.to_imp(false)
  end

  def test_should_create_a_type_entry
    entry = TypeEntry.new(@product_type, {"code" => "333", "name[lang=de]" => "MyName"})
    @product_type << entry
    puts entry.inspect
  end

  def test_entry_should_verity_the_number_of_given_attributes
    assert_raises ArgumentError do
      entry = TypeEntry.new(@product_type, %w{66 myname myname pieces})
    end
  end

  def test_entry_should_reference_other_entries
    entry = TypeEntry.new(@product_type, {"code" => "333", "name[lang=en]" => "MyName"})
    @product_type << entry

    assert_equal "333", entry.get("code")
    assert_equal "MyName", entry.get("name[lang=en]")
  end

  def test_entry_should_validate_against_the_given_type_attributes
    product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de]})
    assert_raise ArgumentError do
      entry = TypeEntry.new(product_type, {"co" => "555"})
    end
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

  def test_should_create_impex_list_from_array
    catalog_version_type = Type.new("CatalogVersion", %w{languages(isocode)})

    entry = TypeEntry.new(catalog_version_type, [%w{en de fr it}])
    assert_equal "en,de,fr,it", entry.languages

    entry2 = TypeEntry.new(catalog_version_type, [["en", nil, "it"]])
    assert_equal "en,it", entry2.languages
  end

  def test_should_resolve_nested_attribtutes_like_localized_names
    #OLD product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de]})

    #TODO implement this feature
    #name = {:name => {:lang => ["en", "de"]}}
    #product_type = Type.new("Product", ["code[unique=true]", name])
    #entry = TypeEntry.new(product_type, %w{555 myproduct555 meinproduct555})

    #assert_equal "meinproduct555", entry.get("name[lang=de]")
    #assert_equal "myproduct555", entry.get("name[lang=en]")
  end

  def test_should_add_a_unique_identifier_on_an_attribute_if_no_is_given
    #TODO implement this feature
    #product_type = Type.new("Product", %w{code name[lang=en] name[lang=de]})
    #assert product_type.attributes.include?("code[unique=true]")
  end

  def test_type_should_unregister_an_entry_by_attribute
    product_type = Type.new("Product", %w{code})
    entry = TypeEntry.new(product_type, %w{555 })

    assert product_type.entries.one?{|e|e.code == "555"}
    product_type.unregister_by("code", "555")
    assert product_type.entries.none?{|e|e.code == "555"}
  end

  def test_type_should_find_entry_by_attribute
    product_type = Type.new("Product", %w{code})
    assert product_type.find_by("code", "555").empty?
    entry = TypeEntry.new(product_type, %w{555})
    entry = TypeEntry.new(product_type, %w{555})
    entry = TypeEntry.new(product_type, %w{556})
    found = product_type.find_by("code", "555")
    assert_equal 2, found.size 
  end
  
  def test_entry_should_match_fuzzy_attribute_names
    product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)}, @macros)
    entry = TypeEntry.new(product_type, %w{555 myproduct555 meinproduct555 pieces SimpexProducts:Online SampleCategory})

    assert_equal "555", entry.get("code")
    assert_equal "pieces", entry.get("unit")
    assert_equal "SampleCategory", entry.get("supercategories")

    assert_raise ArgumentError do
      entry.get("supercat")
    end
  end

  def test_entry_should_match_nested_brakets_attributes
    product_type = Type.new("Product", %w{code[unique=true] catalog(id)[unique=true]})
    entry = TypeEntry.new(product_type, %w{555 myCatalogId})
    assert_equal "myCatalogId", entry.catalog
  end

  def test_entry_should_give_catalog_version_specific_attributes
    product_type = Type.new("Product", %w{code[unique=true] $catalogVersion}, @macros)
    entry = TypeEntry.new(product_type, %w{555 myCatalogId:staged })
    assert_equal "555:myCatalogId:staged", entry.cat_ver_specific("code")

    assert_raise ArgumentError do
      product_type = Type.new("Product", %w{code[unique=true] someattr})
      entry = TypeEntry.new(product_type, %w{555 myCatalogId:staged })
      assert_equal "555:myCatalogId:staged", entry.cat_ver_specific("code")
    end
  end

  def test_entry_should_match_macro_attributes
    product_type = Type.new("Product", %w{code[unique=true] $catalogVersion},"$catalogVersion=asdfadsfasdfasdf")
    entry = TypeEntry.new(product_type, %w{555 myCatalogId})
    assert_equal "myCatalogId", entry.catalogVersion
  end

  def test_entry_should_match_fuzzy_attribute_names_to_real_attributes

    product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)}, @macros)
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

    language_type = Type.new("Language", %w{isocode[unique=true] active})
    TypeEntry.new(language_type, %w{de true})
    TypeEntry.new(language_type, %w{en true})

    catalog_type = Type.new("Catalog", %w{id[unique=true] name[lang=de] name[lang=en] defaultCatalog})
    catalog = TypeEntry.new(catalog_type, %w{simpex_catalog SimpexCatalog SimpexCatalog true})

    catalog_version_type = Type.new("CatalogVersion", %w{catalog(id)[unique=true] version[unique=true] active defaultCurrency(isocode)})
    TypeEntry.new(catalog_version_type, [catalog.id, "online", "true", "EUR"])

    result = ImpexResult.new(impex_dest_dir)
    result << language_type 
    result << catalog_type
    result << catalog_version_type 
    result
  end
end
