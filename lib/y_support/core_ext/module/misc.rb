class Module
  # Creates a module that inherits from the receiver and is parametrized
  # with the given set of parameters. The parameters have form { symbol:
  # value } and they cause singleton method(s) named "symbol" be defined
  # on the heir, returning "value".
  # 
  def heir_module **parameters, &block
    s = self
    Module.new { include s }.tap do |m|
      parameters.each_pair { |symbol, value|
        m.define_singleton_method symbol do value end
      }
      m.define_singleton_method inspect do s.inspect + "<" end
      m.module_exec &block if block
    end
  end

  # Creates a class, which is a subclass of a supplied class (defaults
  # to Object if none supplied), and which also inherits from the receiver
  # and is parametrized by the given set of parameters. The parameters have
  # form { symbol: value } and they cause singleton method(s) named "symbol"
  # be defined on the heir class, returning "value".
  # 
  def heir_class mother=Object, **parameters, &block
    s = self
    Class.new( mother ) { include s }.tap do |c|
      parameters.each_pair { |symbol, value|
        c.define_singleton_method symbol do value end
      }
      # TODO: This line is controversial:
      c.define_singleton_method inspect do s.inspect + "<" end
      c.module_exec &block if block
    end
  end
  
  # Sets a constant to a value if this has not been previously defined.
  # 
  def const_set_if_not_defined( const, value )
    const_set( const, value ) unless const_defined? const
  end

  # Redefines a constant without warning.
  # 
  def const_reset!( const, value )
    send :remove_const, const if const_defined? const
    const_set( const, value )
  end

  # Defines a set of methods by applying the block on the return value of
  # another set of methods. Accepts a hash of pairs { mapped_method_symbol =>
  # original_method_symbol } and a block which to chain to the original
  # method result.
  # 
  def chain **hash, &block
    hash.each_pair { |mapped_method_symbol, original_method_symbol|
      define_method mapped_method_symbol do |*args, &b|
        block.( send original_method_symbol, *args, &b )
      end
    }
  end
end
