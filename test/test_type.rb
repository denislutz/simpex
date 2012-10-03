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

  def test_type_should_validate_the_presence_of_macros_handling_the_unique_propery
    assert_raises ArgumentError do
      Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)})
    end

    macros = ["$catalogVersion=adsfasdfasdf", "$contentCV=someValue"]
    Type.new("MediaReference", %w{uid[unique=true] name referencedDamMedia(code,$contentCV)[lang=$lang] altText[lang=$lang] $contentCV[unique=true]}, macros)
    Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion[unique=true] supercategories(code)}, macros)
    Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code,$catalogVersion) $catalogVersion[unique=true] supercategories(code)}, macros)
  end

  def test_type_should_validate_the_presence_of_macros_if_no_macros_are_given
    assert_raises ArgumentError do
      Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVersion supercategories(code)})
    end
    assert_raises ArgumentError do
        macros = ["$catalogVersion=adsfasdfasdf"]
        Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVe[unique=true] supercategories(code)}, macros)
    end
    macros = ["$catalogVe=adsfasdfasdf"]
    Type.new("Product", %w{code[unique=true] name[lang=en] name[lang=de] unit(code) $catalogVe[unique=true] supercategories(code)}, macros)
  end


  def test_type_should_generate_nothing_if_no_entries
    assert_equal "", @product_type.to_imp(false)
  end



  def test_should_create_impex_list_from_array
    catalog_version_type = Type.new("CatalogVersion", %w{languages(isocode)})

    entry = TypeEntry.new(catalog_version_type, [%w{en de fr it}])
    assert_equal "en,de,fr,it", entry.languages

    entry2 = TypeEntry.new(catalog_version_type, [["en", nil, "it"]])
    assert_equal "en,it", entry2.languages
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

  def test_entry_should_match_nested_brakets_attributes
    product_type = Type.new("Product", %w{code[unique=true] catalog(id)[unique=true]})
    entry = TypeEntry.new(product_type, %w{555 myCatalogId})
    assert_equal "myCatalogId", entry.catalog
  end

end
