require 'test/unit'
require File.expand_path('simpex.rb',  'lib')
require 'fileutils'

class TestRichTypes < Test::Unit::TestCase

  def setup
    @impex_dest_dir = "test/tmp"
    FileUtils.mkdir(@impex_dest_dir) unless Dir.exist?(@impex_dest_dir)
  end

  def teardown
    FileUtils.rm_rf(@impex_dest_dir)
  end

  def test_should_create_catalog_with_specific_type
    file_name = "specific_type.csv"
    assert_equal false, File.exist?(File.expand_path(file_name, "test/tmp"))

    catalog = Catalog.new("id" => "mycatalog")
    assert_not_nil catalog
    assert_equal "mycatalog", catalog.id

    result = ImpexResult.new(@impex_dest_dir)
    result << Catalog.type 
    result.impexify(file_name)
    assert_equal true, File.exist?(File.expand_path(file_name, "test/tmp"))
  end
end
