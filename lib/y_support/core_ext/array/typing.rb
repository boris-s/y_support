#encoding: utf-8
class Array
  # Fails unless the array #include? the argument
  def aE_has( e, msg = "Element #{e} absent from the array" )
    raise AE, msg unless self.include? e
    return self end
  alias :aE_include :aE_has
  alias :aE_∋ :aE_has
end
