require 'test/unit'
require File.expand_path('simpex.rb',  'lib')
require 'fileutils'

class TestResult < Test::Unit::TestCase
  def setup
    macros = []
    macros << "$firstmacro"
    macros << "$secondmacro"

    @category_type = Type.new("Category", %w{code[unique=true] name[lang=de]}, macros)
    @product_type = Type.new("Product", %w{code[unique=true] name[lang=en]}, macros)

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
    result.impexify("result.csv")
    assert File.exist?(@result_file_path), "the file #{@result_file_path} should have been created"
  end

  def teardown
    #File.delete(@result_file_path)
  end

end
