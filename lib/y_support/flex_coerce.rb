# coding: utf-8

require_relative 'core_ext/object'

module FlexCoerce
  require_relative 'flex_coerce/flex_proxy'
  require_relative 'flex_coerce/class_methods'
  require_relative 'flex_coerce/module_methods'

  extend FlexCoerce::ModuleMethods

  # Method #FlexProxy is delegated to the host class, it returns the
  # parametrized subclass of FlexCoerce::FlexProxy specific to the host class.
  # 
  def FlexProxy
    self.class.FlexProxy
  end

  # FlexCoerce provides coerce method that returns a proxy object and self.
  # 
  def coerce first_operand
    return FlexProxy().of( first_operand ), self
  end
end
