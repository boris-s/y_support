#encoding: utf-8

class Module
  # Sets a constant to a value if this has not been previously defined.
  # 
  def const_set_if_not_defined( const, value )
    const_set( const, value ) unless const_defined? const
  end

  # Redefines a constant without warning.
  # 
  def const_redefine!( const, value )
    send :remove_const, const if const_defined? const
    const_set( const, value )
  end
end
