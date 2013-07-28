# encoding: utf-8

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

  # Assigns prescribed atrributes to the object and makes them accessible with
  # getter (reader) methods. Shadows / overwrites existing methods.
  # 
  def set_attr_with_readers! hash
    hash.each_pair { |symbol, value|
      instance_variable_set "@#{symbol}", value
      singleton_class.class_exec { attr_reader symbol }
    }
  end

  # Constructs parametrized subclasses of the supplied classes and makes them
  # available under specified getters. Expects a hash of pairs { reader_symbol:
  # class }, and a hash of parameters, with which the class(es) is (are)
  # parametrized. Raises NameError should any of the getters shadow / overwrite
  # existing methods.
  # 
  def param_class hash, with: (fail ArgumentError, "No parameters!")
    hash.each { |ß, ç|
      sub = ç.parametrize with
      set_attr_with_readers( ß => sub )
    }
    return nil
  end

  # Constructs parametrized subclasses of the supplied classes and makes them
  # available under specified getters. Expects a hash of pairs { reader_symbol:
  # class }, and a hash of parameters, with which the class(es) is (are)
  # parametrized. Shadows / overwrites existing methods.
  # 
  def param_class hash, with: (fail ArgumentError, "No parameters!")
    hash.each { |ß, ç|
      sub = ç.parametrize with
      set_attr_with_readers( ß => sub, **nn )
    }
    return nil
  end
end
