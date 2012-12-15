# -*- coding: utf-8 -*-
class Array
  # Fails unless the array #include? the argument
  def aE_has( e, msg = "Element #{e} absent from the array" )
    raise AE, msg unless self.include? e
    return self end
  alias :a℈_has :aE_has if USE_SCRUPLE
  alias :aE_include :aE_has
  alias :a℈_include :aE_has if USE_SCRUPLE
  alias :aE_∋ :aE_has if USE_SCRUPLE
  alias :a℈_∋ :aE_has if USE_SCRUPLE
end
