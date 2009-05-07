Merb.logger.info("Loaded DEVELOPMENT Environment...")
Merb::Config.use { |c|
  c[:exception_details] = true
  c[:reload_classes] = true
  c[:log_level] = :debug  
  c[:reload_time] = 0.5
  c[:log_auto_flush ] = true  
}

Merb::BootLoader.after_app_loads do
  Merb::Cache.setup do
    register(:default, Merb::Cache::AdhocStore.new)
  end
end

