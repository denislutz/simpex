require 'test/unit'
require File.expand_path('simpex.rb',  'lib')
require 'fileutils'

class TestResult < Test::Unit::TestCase
  def setup

    @category_type = Type.new("Category", %w{code[unique=true] name[lang=de]})
    @product_type = Type.new("Product", %w{code[unique=true] name[lang=en]})

    @impex_dest_dir = "test/tmp"
    FileUtils.mkdir(@impex_dest_dir) unless Dir.exist?(@impex_dest_dir)
    @result_file_path = File.expand_path("result.csv",  @impex_dest_dir)

    #assert !File.exist?(@result_file_path)
  end

  def test_should_collect_all_marcros_in_a_given_file
    entry = TypeEntry.new(@product_type, %w{555 myproduct555})
    entry = TypeEntry.new(@category_type, %w{555 mycategory})

    result = ImpexResult.new(@impex_dest_dir)
    result << @category_type 
    result << @product_type 
    result.impexify("result.csv", false)
    assert File.exist?(@result_file_path), "the file #{@result_file_path} should have been created"
  end

  def test_should_recognize_not_used_macros
    macros = []
    macros << "$firstmacro"
    macros << "$secondmacro"

    @category_type = Type.new("Category", %w{code[unique=true] name[lang=de]}, macros)
    @product_type = Type.new("Product", %w{code[unique=true] name[lang=en]}, macros)

    result = ImpexResult.new(@impex_dest_dir)
    result << @category_type 
    result << @product_type


    entry = TypeEntry.new(@product_type, %w{555 myproduct555})
    entry = TypeEntry.new(@category_type, %w{555 mycategory})

    assert_raises ArgumentError do
      result.impexify("result.csv", false)
    end 

    @product_type = Type.new("Product", %w{code[unique=true] name[lang=en] $firstmacro}, macros)
    result = ImpexResult.new(@impex_dest_dir)
    result << @category_type 
    result << @product_type
    assert_raises ArgumentError do
      result.impexify("result.csv", false)
    end

    @product_type = Type.new("Product", %w{code[unique=true] name[lang=en] $firstmacro}, macros)
    @category_type = Type.new("Category", %w{code[unique=true] name[lang=de] $secondmacro}, macros)
    result = ImpexResult.new(@impex_dest_dir)
    result << @category_type 
    result << @product_type
    result.impexify("result.csv", false)
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
