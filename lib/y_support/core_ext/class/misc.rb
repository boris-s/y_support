class Class
  # Creates a subclass of the current class parametrized with a given set of
  # parameters. The parameters have form { symbol: value } and they cause
  # singleton method(s) named "symbol" be defined on the subclass, returning
  # "value".
  # 
  def parametrized_subclass **parameters, &block
    Class.new( self ).tap do |subclass|
      parameters.each_pair { |symbol, value|
        subclass.define_singleton_method symbol do value end
      }
      subclass.define_singleton_method inspect do subclass.superclass.inspect + "<" end
      subclass.class_exec &block if block
    end
  end
  alias parametrize parametrized_subclass

  # Method #heir_module is not applicable to classes, raises TypeError.
  # 
  def heir_module
    fail TypeError, "Method #heir_module is not applicable to classes!"
  end
end
