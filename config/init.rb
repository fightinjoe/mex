require 'ruby-debug'

Language::English::Inflect.plural_word('mex','mexes')
Merb::Router.prepare do |r|

  r.match('/').to(:controller => 'mexes', :action =>'index')

  r.match('/query.js').
    to(:controller => 'mexes', :action => 'query', :format => 'js').
    name(:query_js)

  r.match('/query.rss').
    to(:controller => 'mexes', :action => 'query', :format => 'xml').
    name(:query_rss)


  r.match('/delete_all.js').
    to(:controller => 'mexes', :action => 'delete_all', :format => 'js').
    name(:delete_all)

  r.resources :mexes

end

Merb::Config.use { |c|
  c[:app_name]            = "MeX - Merb Exception Tracker"
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

dependencies 'merb_datamapper', 'merb-builder'