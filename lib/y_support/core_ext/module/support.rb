#encoding: utf-8

class Module
  # Further automation of soon-to-be-deprecated #autorequire.
  # 
  def autoreq( *symbols, descending_path: '..', ascending_path_prefix: 'lib' )

    require 'active_support/core_ext/string/inflections'

    namespace = self.name
    namespace_path = namespace.underscore
    namespace_chain = namespace.split "::"
    ascending_path = ascending_path_prefix + '/' + namespace_path
    symbols.map( &:to_s ).each { |ς|
      next if ς.strip.empty?
      camelized_ß = ς.camelize.to_sym
      path = './' + [ descending_path, ascending_path, ς ].join( '/' )
      autoload camelized_ß, path
    }
  end
  
  # I didn't write this method by myself.
  # 
  def attr_accessor_with_default *symbols, &block
    raise 'Default value in block required' unless block
    symbols.each { |ß|
      module_eval {
        attr_writer ß
        define_method ß do
          class << self; self end.module_eval { attr_reader(ß) }
          if instance_variables.include? "@#{ß}" then 
            instance_variable_get "@#{ß}"
          else
            instance_variable_set "@#{ß}", block.call
          end
        end
      }
    }
  end
  alias :attr_accessor_w_default :attr_accessor_with_default
end
