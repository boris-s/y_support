#encoding: utf-8
class Array
  # === Duck typing support (aka. runtime assertions)

  # This method takes a block and fails with TypeError, if the receiver array
  # fails to include the specified element. An optional argument customizes the
  # error message (element description).
  # 
  def aT_includes element, what_is_element=nil
    e = what_is_element ? what_is_element.to_s.capitalize :
      "Element (#{element.class} instance)"
    m = "#{e} is absent from the array."
    raise TErr, m unless include? element
    return self
  end
  alias :aT_include :aT_includes
end
