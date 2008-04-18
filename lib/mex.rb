# make sure we're running inside Merb
if defined?(Merb::Plugins)


  # Merb gives you a Merb::Plugins.config hash...feel free to put your stuff in your piece of it
  Merb::Plugins.config[:mex] = {
    :chickens => false
  }
  
  Merb::BootLoader.before_app_loads do
  end

  Merb::BootLoader.after_app_loads do
    require 'mex/application'
    Language::English::Inflect.plural_word('mex','mexes')
    Merb::Router.prepend do |r|
      r.match('/mex').to(:controller => 'mexes', :action => 'index')

      r.match('/mex/query.js').
        to(:controller => 'mexes', :action => 'query', :format => 'js').
        name(:query_js)

      r.match('/mex/query.rss').
        to(:controller => 'mexes', :action => 'query', :format => 'xml').
        name(:query_rss)


      r.match('/mex/delete_all.js').
        to(:controller => 'mexes', :action => 'delete_all', :format => 'js').
        name(:delete_all)

      r.resources :mexes
    end
  end
  
  Merb::Plugins.add_rakefiles "mex/merbtasks"
end