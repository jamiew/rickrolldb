Merb.logger.info("Loaded PRODUCTION Environment...")
Merb::Config.use { |c|
  c[:exception_details] = false
  c[:reload_classes] = false
  c[:log_level] = :info # normally just :error
  #c[:log_file] = Merb.log_path + "/production.log"
  c[:log_file] = "log/production.log"

}
