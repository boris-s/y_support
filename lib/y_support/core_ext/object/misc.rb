# encoding: utf-8

require File.dirname( __FILE__ ) + '/../module'
require File.dirname( __FILE__ ) + '/../class'

class Object
  # Assigns prescribed atrributes to the object and makes them accessible with
  # getter (reader) methods. Raises NameError should any of the getters shadow /
  # overwrite existing methods.
  # 
  def set_attr_with_readers hash
    hash.each_pair { |ß, value|
      fail NameError, "Method \##{ß} already defined!" if methods.include? ß
      set_attr_with_readers! ß => value
    }
  end

  # Like +#set_attr_with_readers+, but it overloads existing methods, if present.
  # Whereas +#set_attr_with_readers+ guards against the presence of methods with
  # the same name, +#set_attr_with_reader!+ overloads them in the following way:
  #
  # * Colliding instance method defined in the singleton class of the receiver
  #   is overwritten (redefined).
  # * Colliding instance methods defined on the receiver's class ancestors are
  #   overloaded (partially shadowed). If the method message is sent without
  #   arguments or block, the reader activates and returns the corresponding
  #   instance variable regardless of what the behavior of the shadowed method
  #   might have been. However, if the method message is sent with arguments
  #   or block, the original method is invoked (via +super+) and its result
  #   returned.
  # 
  def set_attr_with_readers! hash
    hash.each_pair { |ß, value|
      instance_variable_set "@#{ß}", value
      singleton_class.class_exec do
        define_method ß do |*args, &block|
          return instance_variable_get "@#{ß}" if args.empty? && block.nil?
          super *args, &block
        end
      end
    }
  end

  # Constructs heir classes (parametrized subclasses) of the supplied modules
  # (classes) and makes them available under specified getters. Expects a hash of
  # pairs { symbol: class }, and a hash of parameters with which to parametrize
  # the modules (classes). The methods guards against collisions in the subclass
  # getter symbols, rasing +NameError+ should these shadow or overwrite existing
  # methods.
  # 
  def param_class( hash, with: {} )
    hash.each { |ß, m|
      case m
      when Class then
        parametrized_subclass = m.parametrize( with )
        set_attr_with_readers( ß => parametrized_subclass )
      when Module then
        heir_class = m.heir_class( with )
        set_attr_with_readers( ß => heir_class )
      else fail TypeError, "#{m} must be a module or a class!"
      end
    }
    return nil
  end

  # Like +#param_class+, but it shadows or overwrites existing methods colliding
  # with the getters of the parametrized classes. See +#set_attr_with_readers!"
  # for full explanation of the shadowing / overwriting behavior.
  # 
  def param_class!( hash, with: {} )
    hash.each { |ß, m|
      case m
      when Class then
        parametrized_subclass = m.parametrize( with )
        set_attr_with_readers!( ß => parametrized_subclass )
      when Module then
        heir_class = m.heir_class( with )
        set_attr_with_readers!( ß => heir_class )
      else fail TypeError, "#{m} must be a module or a class!"
      end
    }
    return nil
  end
end
