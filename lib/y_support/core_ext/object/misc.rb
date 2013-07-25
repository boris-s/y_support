# encoding: utf-8

require 'y_support/core_ext/module/misc'

class Object
  # Sets a constant to a value if this has not been previously defined.
  # 
  def const_set_if_not_defined( const, value )
    singleton_class.const_set_if_not_defined( const, value )
  end

  # Redefines a constant without warning.
  # 
  def const_reset! const, value
    singleton_class.const_reset! const, value
  end

  # Assigns prescribed atrributes to the object and makes them accessible with
  # getter (reader) methods. Optional argument +:overwrite_methods+ enables the
  # readers to overwrite existing methods.
  # 
  def set_attr_with_readers( overwrite_methods: false, **hash )
    hash.each_pair { |symbol, value|
      instance_variable_set "@#{symbol}", value
      fail NameError, "Method \##{symbol} already defined!" if
        methods.include? symbol unless overwrite_methods == true
      singleton_class.class_exec { attr_reader key }
    }
  end

  # Expects one name of a class, and a hash of parameters, and establishes
  # a subclass of the supplied class name, parametrized with the hash of
  # parameters. The parametrized subclass is then assigned to the appropriately
  # named instance variable owned by the receiver class. Also, attribute reader
  # is established in the receiver class, providing access to the newly created
  # parametrized subclass.
  # 
  def has_parametrized_class name, **parameters
    subclass = const_get( name ).parametrize **parameters
    instance_variable_set "@#{name}", subclass
    class_exec do attr_reader( name ) end
  end
end
