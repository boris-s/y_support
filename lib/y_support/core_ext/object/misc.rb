# encoding: utf-8

require File.dirname( __FILE__ ) + '/../module'
require File.dirname( __FILE__ ) + '/../class'

class Object
  # Assigns atrributes to the receiver object and makes them
  # accessible via reader methods (aka. getter or selector
  # methods). Raises `NameError` in case of name collisions with
  # existing methods of the receiver object.
  # 
  def set_attr_with_readers hash
    hash.each_pair { |ß, value|
      fail NameError, "Method \##{ß} already defined on " \
        "#{self}! Use #set_attr_with_readers! to overload " \
        "preexisting methods." if methods.include? ß
      set_attr_with_readers! ß => value
    }
  end
  alias set_attr_with_selectors set_attr_with_readers

  # Like +#set_attr_with_readers+, but overloads existing methods
  # if their names collied with the attributes to be set.
  # Overloading is performed in the following way: If the attribute
  # reader is called without parameters, it acts as an attribute
  # reader (as expected). If the user tries to invoke the attribute
  # method with parameters (or a block), the message falls through
  # to the colliding instance method. In this way, both methods
  # are preserved -- collision only happens if the colliding
  # method took no parameters.
  # 
  def set_attr_with_readers! hash
    hash.each_pair { |ß, value|
      # puts "Setting @#{ß} of #{self} to #{value}."
      instance_variable_set "@#{ß}", value
      singleton_class.class_exec do
        define_method ß do |*args, &block|
          return instance_variable_get "@#{ß}" if
            args.empty? && block.nil?
          super *args, &block
        end
      end
    }
  end

  # Constructs heir classes (parametrized subclasses) of the
  # supplied modules (classes) and makes them available under
  # specified getters. Expects a hash of pairs { symbol: class },
  # and a hash of parameters with which to parametrize the modules
  # (classes). The methods guards against collisions in the
  # subclass getter symbols, rasing +NameError+ should these shadow
  # or overwrite existing methods.
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

  # Like +#param_class+, but it shadows or overwrites existing
  # methods colliding with the getters of the parametrized
  # classes. See +#set_attr_with_readers!"  for full explanation of
  # the shadowing / overwriting behavior.
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

  # New syntax for #param_class method for creating parametrized
  # subclasses.
  #
  def owns_subclass( name, of:, parametrized_by: {},
                    named: proc do |**params|
                      param_str = params.empty? ? "" :
                                    "[#{params.pretty_print}]"
                      "#{name}#{param_str}>"
                    end,
                    overwrite_existing_methods: true )
    if overwrite_existing_methods then
      param_class!( { name => of }, with: parametrized_by )
    else
      param_class( { name => of }, with: parametrized_by )
    end
    # FIXME: This method cannot stay like this. It is not possible
    # for has_subclass method expecting a single class to subclass
    # to rely on param_class method which is intended for multiple
    # classes. Simplify simplify simplify. And change that SO
    # answer when done.
  end
end
