# encoding: utf-8

class Object
  # Assigns prescribed atrributes to the object and makes them accessible with
  # getter (reader) methods. Optional argument +:overwrite_methods+ enables the
  # readers to overwrite existing methods.
  # 
  def set_attr_with_readers( overwrite_methods: false, **hash )
    hash.each_pair { |symbol, value|
      instance_variable_set "@#{symbol}", value
      fail NameError, "Method \##{symbol} already defined!" if
        methods.include? symbol unless overwrite_methods == true
      singleton_class.class_exec { attr_reader symbol }
    }
  end

  # Expects a hash of pairs { name: class }, and a hash of parameters. Creates
  # subclasses parametrized with the supplied parameters as the object attributes
  # and makes them accessible under the supplied names (as reader methods).
  # 
  def parametrizes hash, with: (fail ArgumentError, "No parameters!")
    hash.each { |ß, ç| set_attr_with_readers ß => ç.parametrize( **with ) }
    return nil
  end
end
