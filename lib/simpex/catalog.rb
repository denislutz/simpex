class Catalog < TypeEntry

  def initialize(values)
    super(@@type, values)
  end

  @@type = Type.new("Catalog", %w{activeCatalogVersion(catalog(id),version) backRefPK buyer(uid) creationtime[forceWrite=true,dateformat=dd.MM.yyyy hh:mm:ss] defaultCatalog[allownull=true] id[unique=true,allownull=true] name[lang=de] name[lang=en] name[lang=fr] name[lang=it] owner(Customer.uid) previewURLTemplate supplier(uid) urlPatterns})

  def Catalog.type
    @@type
  end
end
