#encoding: utf-8
class Array
  # === Duck typing support (aka. runtime assertions)

  # This method takes a block and fails with TypeError, if the receiver array
  # fails to include the specified element. An optional argument customizes the
  # error message (element description).
  # 
  def tE_includes element, what_is_element=nil
    e = what_is_element ? what_is_element.to_s.capitalize :
      "Element (#{element.class} instance)"
    m = "#{e} is absent from the array."
    raise TErr, m unless include? e
    return self
  end
  alias :tE_include :tE_includes
end
