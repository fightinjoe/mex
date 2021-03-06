require 'forwardable'
require 'datamapper_ext'

class Mexes < Merb::Controller
  # before :require_basic_authentication

  def _template_location(action, type = nil, controller = controller_name)
    undo   = Merb.load_paths[:view].first.gsub(%r{[^/]+}, '..')
    prefix = File.dirname(__FILE__)
    file   = controller == "layout" ? "layout.#{action}.#{type}" : "#{action}.#{type}"
    File.join( '.', undo, prefix, 'views', file )
  end

  def index
    @exception_names    = Mex.find_exception_class_names
    @controller_actions = Mex.find_exception_controllers_and_actions
    @app_names          = Mex.find_app_names
    query
  end

  def query
    provides :html, :js, :xml

    conditions = []
    parameters = []
    unless params[:id].blank?
      conditions << 'id = ?'
      parameters << params[:id]
    end
    unless params[:query].blank?
      conditions << 'message LIKE ?'
      parameters << "%#{params[:query]}%"
    end
    unless params[:date_ranges_filter].blank?
      conditions << 'created_at >= ?'
      parameters << params[:date_ranges_filter].to_f.days.ago.utc
    end
    unless params[:exception_names_filter].blank?
      conditions << 'exception_class = ?'
      parameters << params[:exception_names_filter]
    end
    unless params[:app_names_filter].blank?
      conditions << 'app_name = ?'
      parameters << params[:app_names_filter]
    end
    unless params[:controller_actions_filter].blank?
      conditions << 'controller_name = ? AND action_name = ?'
      parameters += params[:controller_actions_filter].split('/').collect(&:downcase)
    end
    @exceptions = Mex.paginate( conditions.empty? ? nil : parameters.unshift(conditions * ' and ') )

    render :layout => false
  end

  def show
    provides :html, :js
    @exc = Mex.get( params[:id] )
    render
  end

  def create
    Mex.create( params[:mex] )
    'Thank you'
  end

  def delete
    provides :js
    Mex.get( params[:id] ).destroy!
    render :layout => false
  end

  def delete_all
    provides :js
    unless params[:ids].blank?
      ids = params[:ids].split(',').collect(&:to_i)
      Mex.all( :id.in => ids ).each { |l| l.destroy! }
    end
    query
  end

  private
  @@http_auth_headers = %w(Authorization HTTP_AUTHORIZATION X-HTTP_AUTHORIZATION X_HTTP_AUTHORIZATION REDIRECT_X_HTTP_AUTHORIZATION)

  def access_denied_with_basic_auth
    headers["Status"]           = "Unauthorized"
    headers["WWW-Authenticate"] = %(Basic realm="Web Password")
    render :text => "Could't authenticate you", :status => '401 Unauthorized'
  end

  def require_basic_authentication
    auth_key  = @@http_auth_headers.detect { |h| request.env.has_key?(h) }
    auth_data = request.env[auth_key].to_s.split unless auth_key.blank?
    username, password =  (auth_data && auth_data[0] == 'Basic') ?
      Base64.decode64(auth_data[1]).split(':')[0..1] :
      [nil,nil]

    authenticate( username, password )
  end

  def authenticate( user, pass )
    unless user == 'user' && pass == 'pass'
      access_denied_with_basic_auth
    end
  end

end

# class Exceptions < Merb::Controller; end

module Merb
  module MexesHelper
    def link( content, url, attrs = {} )
      attrs[:href] = url
      attrs = attrs.to_a.collect { |key,val| '%s="%s"' % [key,val] }
      "<a %s >%s</a>" % [ attrs, content ]
    end

    def remote_link( content, js, attrs = {} )
      url             = '#'
      attrs[:onclick] = '%s;return false;' % js
      link( content, url, attrs )
    end

    def filtered?
      [:query, :date_ranges_filter, :exception_names_filter, :controller_actions_filter].any? { |p| params[p] }
    end

    def pagination_remote_links(paginator, options={}, html_options={})
       name   = options[:name]    || ActionController::Pagination::DEFAULT_OPTIONS[:name]
       params = (options[:params] || ActionController::Pagination::DEFAULT_OPTIONS[:params]).clone

       'links go here'
       #pagination_links_each(paginator, options) do |n|
       #  params[name] = n
       #  link_to_function n.to_s, "ExceptionLogger.setPage(#{n})"
       #end
    end

    def cycle( *opts )
      @cycle = @cycle ? @cycle+1 : 0
      opts[ @cycle % opts.size ]
    end

    def print_hash( hash )
      return hash unless hash.is_a?( Hash )
      max = hash.keys.max { |a,b| a.to_s.length <=> b.to_s.length }
      out = hash.keys.collect(&:to_s).sort.inject [] do |out, key|
        out << '* ' + ("%*s: %s" % [max.to_s.length, key, hash[key].to_s.strip])
      end

      "<pre>\n#{ out * "\n" }</pre>"
    end

    def print_page_links( paginated_object )
      links = []
      paginated_object.number_of_pages.times do |i|
        links << link( i+1, url(:action => 'index', :page => i+1) )
      end
      links * ' '
    end

    def to_rfc822( datetime )
      d = datetime
      ::Time.local(d.year, d.month, d.day, d.hour, d.min, d.sec).rfc822
    end
  end
end

# This is a temporary fix until DataMapper 0.9 is released
# with support for custom types
module DataMapperExt
  def self.included(base)
    base.send :extend, ClassMethods
  end

  module ClassMethods
    private

    # Provides a way for storing objects as YAML in the database.
    # Not ideal, as this can be polymorphically abused, but a good
    # start towards typecasting
    #
    # ==== Example
    #  require 'datamapper_ext'
    #  MyClass < DataMapper::Base
    #    include DataMapperExt
    #    ...
    #    yaml_attribute :my_hash, :my_array
    #    ...
    #
    def yaml_attribute( *attributes )
      for attribute in attributes
        instance_variable = "@#{ attribute }"
        cache_variable    = "#{ instance_variable }_cache"
        getter            = attribute.to_s
        setter            = "#{ getter }="

        class_eval <<-EOS
          def #{ getter }
            #{ cache_variable } ||= #{ instance_variable } && YAML.load( #{ instance_variable } )
          end

          def #{ setter }( hash )
            if hash.is_a?( Hash ) || hash.is_a?( Array )
              #{ cache_variable } = hash
              hash = hash.to_yaml
            end
            #{ instance_variable } = hash
          end
        EOS
      end
    end
  end

end

class Mex < DataMapper::Base
  include DataMapperExt
  set_table_name('mexes')

  property :app_name,        :string
  property :exception_class, :string
  property :controller_name, :string
  property :action_name,     :string
  property :message,         :text
  property :backtrace,       :text
  property :cookies,         :text
  property :session,         :text
  property :params,          :text
  property :environment,     :text
  property :url,             :text
  property :created_at,      :datetime

  yaml_attribute :cookies, :backtrace, :params, :session, :environment

  ### Class Methods ###

  def self.create_from_controller( controller )
    e_params, request = controller.params, controller.request
    params = {}
    params[:controller_name], params[:action_name] = e_params[:original_params][:controller], e_params[:original_params][:action]
    params[:params]    = e_params[ "original_params" ]
    params[:session]   = controller.session.data
    params[:exception] = e_params[:exception]
    self.create( params )
  end

  def self.find_exception_class_names
    find_by_sql( 'SELECT DISTINCT exception_class FROM mexes;' )
  end

  def self.find_exception_controllers_and_actions
    sql = 'SELECT DISTINCT controller_name, action_name FROM mexes;'
    find_by_sql(sql).collect{ |c| "#{c.controller_name}/#{c.action_name}"}
  end

  def self.find_app_names
    find_by_sql( 'SELECT DISTINCT app_name FROM mexes;' )
  end

  # Pagination support

  def self.per_page() 20; end

  def self.paginate( conditions )
    Paginator.new( count( :conditions => conditions ), per_page ) do |offset, per_page|
      all( :conditions => conditions, :limit => per_page, :offset => offset, :order => 'created_at desc' )
    end
  end

  ### Instance Methods ###

  def exception=( e )
    self.exception_class = e.name
    self.message         = e.message
    self.backtrace       = e.backtrace
  end

  def request=( req )
    self.environment = req.env.merge( 'process' => $$ )
    self.url         = "#{req.protocol}#{req.env["HTTP_HOST"]}#{req.uri}"
    #environment = env << "* Process: #{$$}" << "* Server : #{self.class.host_name}") * "\n")
  end

  def controller_action
    '%s/%s' % [ controller_name.to_s.camel_case, action_name ]
  end

end

# by Bruce Williams
# http://codefluency.com
class Paginator
  
  VERSION = '1.1.0'
  
  include Enumerable

  class ArgumentError < ::ArgumentError; end
  class MissingCountError < ArgumentError; end
  class MissingSelectError < ArgumentError; end  
  
  attr_reader :per_page, :count 
  
  # Instantiate a new Paginator object
  #
  # Provide:
  # * A total count of the number of objects to paginate
  # * The number of objects in each page
  # * A block that returns the array of items
  #   * The block is passed the item offset 
  #     (and the number of items to show per page, for
  #     convenience, if the arity is 2)
  def initialize(count, per_page, &select)
    @count, @per_page = count, per_page
    unless select
      raise MissingSelectError, "Must provide block to select data for each page"
    end
    @select = select
  end
  
  # Total number of pages
  def number_of_pages
     (@count / @per_page).to_i + (@count % @per_page > 0 ? 1 : 0)
  end
  
  # First page object
  def first
    page 1
  end
  
  # Last page object
  def last
    page number_of_pages
  end
  
  def each
    1.upto(number_of_pages) do |number|
      yield page(number)
    end
  end
  
  # Retrieve page object by number
  def page(number)
    number = (n = number.to_i) > 0 ? n : 1
    Page.new(self, number, lambda { 
      offset = (number - 1) * @per_page
      args = [offset]
      args << @per_page if @select.arity == 2
      @select.call(*args)
    })
  end
  
  # Page object
  #
  # Retrieves items for a page and provides metadata about the position
  # of the page in the paginator
  class Page
    
    include Enumerable
        
    attr_reader :number, :pager
    
    def initialize(pager, number, select) #:nodoc:
      @pager, @number = pager, number
      @offset = (number - 1) * pager.per_page
      @select = select
    end
    
    # Retrieve the items for this page
    # * Caches
    def items
      @items ||= @select.call
    end
    
    # Checks to see if there's a page before this one
    def prev?
      @number > 1
    end
    
 #   # Get previous page (if possible)
   def prev
     @pager.page(@number - 1) if prev?
   end
    
    # Checks to see if there's a page after this one
    def next?
      @number < @pager.number_of_pages
    end
    
    # Get next page (if possible)
   def next
     @pager.page(@number + 1) if next?
   end
    
    # The "item number" of the first item on this page
    def first_item_number
      1 + @offset
    end
    
    # The "item number" of the last item on this page
    def last_item_number
      if next?
        @offset + @pager.per_page
      else
        @pager.count
      end
    end
    
    def ==(other) #:nodoc:
      @pager == other.pager && self.number == other.number
    end
    
    def each(&block)
      items.each(&block)
    end
    
    def method_missing(meth, *args, &block) #:nodoc:
      if @pager.respond_to?(meth)
        @pager.__send__(meth, *args, &block)
      else
        super
      end
    end
    
  end
  
end