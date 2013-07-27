# encoding: utf-8

class Object
  # Assigns prescribed atrributes to the object and makes them accessible with
  # getter (reader) methods. Optional argument +:overwrite_methods+ enables the
  # readers to overwrite existing methods.
  # 
  def set_attr_with_readers( hash )
    hash.each_pair { |symbol, value|
      instance_variable_set "@#{symbol}", value
      fail NameError, "Method \##{symbol} already defined!" if
        methods.include? symbol unless hash[:overwrite_methods] == true
      singleton_class.class_exec { attr_reader symbol }
    }
  end

  # Makes the receiver own parametrized subclasses of the supplied classes.
  # Expects a hash of pairs { reader_symbol: class }, and a hash of parameters,
  # with which the class(es) is (are) parametrized. Parametrized subclasses
  # are made accessible under the supplied reader symbol.
  # 
  def param_class hash, with: (fail ArgumentError, "No parameters!"), **nn
    hash.each { |ß, ç|
      sub = ç.parametrize with
      set_attr_with_readers( ß => sub, **nn )
    }
    return nil
  end
end
