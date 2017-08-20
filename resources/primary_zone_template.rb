PrimaryZone = Struct.new(:name, :type)

property :bind_config, String, default: 'default'

property :soa, Hash, default: {}
property :records, Array, default: []
property :default_ttl, [String, Integer], default: 86400

property :template_cookbook, String, default: 'bind'
property :template_name, String, default: 'primary_zone.erb'

action :create do
  bind_config = with_run_context :root do
    find_resource!(:bind_config, new_resource.bind_config)
  end

  bind_service = with_run_context :root do
    find_resource!(:bind_service, bind_config.bind_service)
  end

  # Assume records with no owner field are those belonging to the zone.
  # Split them out so that we can render them at the top of the zone.
  records, zone_records = new_resource.records.partition do |r|
    r.key?(:owner) && !r[:owner].nil? && !r[:owner].empty?
  end

  soa = {
    serial: '1',
    mname: 'localhost.',
    rname: 'hostmaster.localhost.',
    refresh: '1w',
    retry: '15m',
    expire: '52w',
    minimum: 30,
  }.merge(new_resource.soa)

  template new_resource.name do
    path "#{bind_service.vardir}/primary/db.#{new_resource.name}"
    owner bind_service.run_user
    group bind_service.run_group
    cookbook new_resource.template_cookbook
    source new_resource.template_name
    variables(
      default_ttl: new_resource.default_ttl,
      soa: soa,
      zone_records: zone_records.sort_by { |record| [record[:type], record[:rdata]] },
      records: records.sort_by { |record| [record[:owner], record[:type], record[:rdata]] }
    )
    mode 0o440
    action :create
  end

  bind_config_template = with_run_context :root do
    find_resource!(:template, bind_config.conf_file)
  end

  bind_config_template.variables[:primary_zones] << PrimaryZone.new(
    new_resource.name
  )
end
