require 'ruby-debug'

Language::English::Inflect.singular_word('axe','axes')
Merb::Router.prepare do |r|

  r.match('/').to(:controller => 'axes', :action =>'index')

  r.match('/query.js').
    to(:controller => 'axes', :action => 'query', :format => 'js').
    name(:query_js)

  r.match('/delete_all.js').
    to(:controller => 'axes', :action => 'delete_all', :format => 'js').
    name(:delete_all)

  r.resources :axes

end

Merb::Config.use { |c|
  c[:environment]         = 'production',
  c[:framework]           = {},
  c[:log_level]           = 'debug',
  c[:use_mutex]           = false,
  c[:session_store]       = 'cookie',
  c[:session_id_key]      = '_mex_session_id',
  c[:session_secret_key]  = '957821503957cdcbc0bcbe78c6747435c504b40b',
  c[:exception_details]   = true,
  c[:reload_classes]      = true,
  c[:reload_time]         = 0.5
}

dependencies 'merb_datamapper'