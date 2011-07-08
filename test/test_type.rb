require 'test/unit'
require File.expand_path('type.rb', 'src')
require File.expand_path('type_entry.rb', 'src')

class TestType < Test::Unit::TestCase
  #Sample Impex
  #
  #INSERT_UPDATE Category;code[unique=true];$catalogVersion;name[lang=de];name[lang=en];description[lang=de];description[lang=en];
  #;SampleCategory;SimpexProducts:Online;Testkategorie;Sample category;Dies ist eine Testkategorie;This is a sample category;
  # 
  #
  #INSERT_UPDATE Product;code[unique=true];name[lang=en]; name[lang=de];unit(code);$catalogVersion; description[lang=en]; description[lang=de]; approvalStatus(code);supercategories(code)
  #;sampleproduct1;SampleProduct1;Testprodukt1;pieces;SimpexProducts:Online;"This is a sample product";"Dies ist ein Testprodukt";approved;SampleCategory
  #;sampleproduct2;SampleProduct2;Testprodukt2;pieces;SimpexProducts:Online;"This is another sample product";"Dies ist ein weiteres Testprodukt";approved;SampleCategory

  def setup
    macros = "$catalogversion=catalogversion(catalog(id[default='simpexproducts']), version[default='staged'])[unique=true,default='simpexproducts:staged']"

    @category_type = Type.new("Category", %w{code[unique=true] $catalogVersion name[lang=de] name[lang=en]}, macros)

    @product_type = Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)}, macros)
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
  end

  def test_entry_should_accept_array_of_values_and_assign_them_to_columns_according_to_the_order
    entry = TypeEntry.new(@product_type, %w{555 myproduct555 meinproduct555 pieces SimpexProducts:Online SampleCategory})
    assert_equal "myproduct555", entry.get("name[lang=en]")
    assert_equal "meinproduct555", entry.get("name[lang=de]")
    assert_equal "SampleCategory", entry.get("supercategories(code)")
  end
end
