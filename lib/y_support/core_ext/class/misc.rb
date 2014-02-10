#encoding: utf-8

class Class
  # Creates a subclass of the current class parametrized with a given set of
  # parameters. The parameters have form { symbol: value } and they cause
  # singleton method(s) named "symbol" be defined on the subclass, returning
  # "value".
  # 
  def parametrize parameters, &block
    Class.new( self ).tap do |subclass|
      parameters.each_pair { |symbol, value|
        subclass.define_singleton_method symbol do value end
      }
      subclass.define_singleton_method inspect do subclass.superclass.inspect + "<" end
      subclass.class_exec &block
    end
  end
end
