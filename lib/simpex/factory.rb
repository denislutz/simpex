class Factory 
  def Factory.generate_base_catalog_setup_to_file(impex_dest_dir, result_file_name)
    result = ImpexResult.new(impex_dest_dir)

    language_type = Type.new("Language", %w{isocode[unique=true] active})
    language_type << TypeEntry.new(language_type, %w{de true})
    language_type << TypeEntry.new(language_type, %w{en true})
    result << language_type 

    catalog_type = Type.new("Catalog", %w{id[unique=true] name[lang=de] name[lang=en] defaultCatalog})
    catalog = TypeEntry.new(catalog_type, %w{simpex_catalog SimpexCatalog SimpexCatalog true})
    catalog_type << catalog
    result << catalog_type

    catalog_version_type = Type.new("CatalogVersion", %w{catalog(id)[unique=true] version[unique=true] active defaultCurrency(isocode)})
    catalog_version = TypeEntry.new(catalog_version_type, [catalog.id, "online", "true", "EUR", "de,en"])
    catalog_version_type << catalog_version
    result << catalog_version_type 

    result.impexify(result_file_name)
  end

  def Factory.generate_base_catalog_setup_to(impex_dest_dir)
    result = ImpexResult.new(impex_dest_dir)

    language_type = Type.new("Language", %w{isocode[unique=true] active})
    language_type << TypeEntry.new(language_type, %w{de true})
    language_type << TypeEntry.new(language_type, %w{en true})
    result << language_type 

    catalog_type = Type.new("Catalog", %w{id[unique=true] name[lang=de] name[lang=en] defaultCatalog})
    catalog = TypeEntry.new(catalog_type, %w{simpex_catalog SimpexCatalog SimpexCatalog true})
    catalog_type << catalog
    result << catalog_type

    catalog_version_type = Type.new("CatalogVersion", %w{catalog(id)[unique=true] version[unique=true] active defaultCurrency(isocode)})
    catalog_version = TypeEntry.new(catalog_version_type, [catalog.id, "online", "true", "EUR"])
    catalog_version_type << catalog_version
    result << catalog_version_type 

    result.impexify
  end
end
