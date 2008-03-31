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
            #{ cache_variable } = hash
            #{ instance_variable } = hash.to_yaml
          end
        EOS
      end
    end
  end

end