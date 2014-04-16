class Array
  # Runtime assertions for Array.

  # This method takes a block and fails with TypeError, if the receiver array
  # fails to include the specified element. An optional argument customizes the
  # error message (element description).
  # 
  def aT_include element, what_is_self="array", what_is_element=nil
    m = "%s is absent from #{what_is_self}!" %
      if what_is_element then what_is_element.to_s.capitalize else
        "Element (#{element.class} instance)"
      end
    tap { include? element or fail TypeError, m }
  end

  # Fails with TypeError if the array contains duplicates (using +#uniq+).
  # 
  def aT_uniq what_is_self="array"
    m = "#{what_is_self.to_s.capitalize} non-uniq!"
    tap { self == uniq or fail TypeError, m }
  end

  # Fails with TypeError unless the receiver's +#empty?+ returns _true_.
  # 
  def aT_empty what_is_receiver="array"
    tap { empty? or fail TypeError, "%s not empty".X!( what_is_receiver ) }
  end

  # Fails with TypeError unless the receiver's +#empty?+ returns _false_.
  # 
  def aT_not_empty what_is_receiver="array"
    tap { empty? and fail TypeError, "%s empty".X!( what_is_receiver ) }
  end

  # This method takes a block and fails with +ArgumentError+ if the receiver
  # array fails to include the specified element. An optional argument
  # customizes the error message (element description).
  # 
  def aA_include element, what_is_self="array", what_is_element=nil
    m = "%s is absent from #{what_is_self}!" %
      if what_is_element then what_is_element.to_s.capitalize else
        "Element (#{element.class} instance)"
      end
    tap { include? element or fail ArgumentError, m }
  end

  # Fails with ArgumentError if the array contains duplicates (using +#uniq+).
  # 
  def aA_uniq what_is_self="array"
    m = "#{what_is_self.to_s.capitalize} non-uniq!"
    tap { self == uniq or fail ArgumentError, m }
  end

  # Fails with ArgumentError unless the receiver's +#empty?+ returns _true_.
  # 
  def aA_empty what_is_receiver="array"
    tap { empty? or fail ArgumentError, "%s not empty".X!( what_is_receiver ) }
  end

  # Fails with ArgumentError unless the receiver's +#empty?+ returns _false_.
  # 
  def aA_not_empty what_is_receiver="array"
    tap { empty? and fail ArgumentError, "%s empty".X!( what_is_receiver ) }
  end
end
