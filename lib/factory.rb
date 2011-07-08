require 'simpex'

class Factory 


#INSERT_UPDATE Currency;isocode[unique=true];name[lang=de];name[lang=en];active;base;conversion;digits;symbol
#;EUR;Euro;Euro;true;true;1;2;€
#;USD;US-Dollar;US Dollar;true;false;1,38;2;$
#
#INSERT_UPDATE Country;isocode[unique=true];name[lang=de];name[lang=en];active;
#;at;Österreich;Austria;true;
#;de;Deutschland;Germany;true;
#  
#INSERT_UPDATE Category;code[unique=true];$catalogversion;name[lang=de];name[lang=en];$supercategories
#;$testCategory0-id;;$testCategory0-id;$testCategory0-id;
#;$testCategory1-id;;$testCategory1-id;$testCategory1-id;$testCategory0-id
#;$testCategory2-id;;$testCategory2-id;$testCategory2-id;$testCategory0-id
#;$testCategory3-id;;$testCategory3-id;$testCategory3-id;$testCategory2-id
#
#INSERT_UPDATE Product;code[unique=true];$catalogversion;name[lang=de];name[lang=en];unit(code);$prices;approvalStatus(code);owner(Principal.uid);startLineNumber;$supercategories
#;$testProduct0-id;;$testProduct0-idde;$testProduct0-iden;pieces;157 EUR;approved;admin;0;$testCategory0-id
#;$testProduct1-id;;$testProduct1-idde;$testProduct1-iden;pieces;157 EUR;approved;admin;0;$testCategory0-id,$testCategory1-id
#;$testProduct2-id;;$testProduct2-idde;$testProduct2-iden;pieces;157 EUR;approved;admin;0;$testCategory0-id,$testCategory2-id
#;$testProduct3-id;;$testProduct3-idde;$testProduct3-iden;pieces;157 EUR;approved;admin;0;$testCategory0-id,$testCategory3-id
#;$testProduct4-id;;$testProduct4-idde;$testProduct4-iden;pieces;157 EUR;approved;admin;0;$testCategory0-id,$testCategory3-id

  def Factory.generate_base_catalog_setup(attr={})
    result = []

    language_type = Type.new("Language", %w{isocode[unique=true] active})
    language_type << TypeEntry.new(language_type, %w{de true})
    language_type << TypeEntry.new(language_type, %w{en true})
    result << language_type 

    catalog_type = Type.new("Catalog", %w{id[unique=true] name[lang=de] name[lang=en] defaultCatalog})
    catalog = TypeEntry.new(catalog_type, %w{ simpex_catalog simpex_catalog simpex_catalog true})
    catalog_id = catalog.get("id[unique=true]")
    catalog_type << catalog
    result << catalog_type

    catalog_version_type = Type.new("CatalogVersion", %w{catalog(id)[unique=true] version[unique=true] active defaultCurrency(isocode)})
    catalog_version = TypeEntry.new(catalog_version_type, %w{#{catalog_id} online true EUR de,en})
    catalog_version_type << catalog_version
    result << catalog_version_type 

    FileWriter.write(result, {:dest => File.new("basic_setup.csv")}.merge(attr)) 
  end
end
