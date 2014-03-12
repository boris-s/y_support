#encoding: utf-8

class Module
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
