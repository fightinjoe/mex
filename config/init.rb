require 'ruby-debug'

# Move this to application.rb if you want it to be reloadable in dev mode.
Merb::Router.prepare do |r|
  r.match('/').to(:controller => 'axes', :action =>'index')
  r.default_routes
end

Merb::Config.use { |c|
  c[:environment]         = 'production',
  c[:framework]           = {},
  c[:log_level]           = 'debug',
  c[:use_mutex]           = false,
  c[:session_store]       = 'cookie',
  c[:session_id_key]      = '_session_id',
  c[:session_secret_key]  = '957821503957cdcbc0bcbe78c6747435c504b40b',
  c[:exception_details]   = true,
  c[:reload_classes]      = true,
  c[:reload_time]         = 0.5
}

dependencies 'merb_datamapper'