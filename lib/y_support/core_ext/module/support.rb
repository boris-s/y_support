#encoding: utf-8

class Module
  # Further automation of soon-to-be-deprecated #autorequire.
  # 
  def autoreq( *ßs )
    options = ßs.extract_options!
    this_ɴspace = self.name
    this_ɴspace_path = this_ɴspace.underscore
    ɴspace_chain = this_ɴspace.split "::"
    options.default!( descending_path: '..', ascending_path_prefix: 'lib' )
    descending_path = options[:descending_path]
    ascending_path_prefix = options[:ascending_path_prefix]
    ascending_path = ascending_path_prefix + '/' + this_ɴspace_path
    ßs.each { |ß|
      str = ß.to_s.stripn; next if str.blank?
      camelized_ß = str.camelize.to_sym
      path = './' + [ descending_path, ascending_path, str ].join( '/' )
      autoload camelized_ß, path }
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
