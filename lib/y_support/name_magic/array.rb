# encoding: utf-8

class Array
  # Maps an array to an array of the element names, obtained by applying +#name+
  # method to them. Takes one optional argument, which regulates its behavior
  # regarding unnamed objects. If set to _nil_ (default) unnamed objects will
  # be mapped to _nil_ (default behavior of the +#name+ method). If set to
  # _true_, unnamed objects will be mapped to themselves. If set to _false_,
  # unnamed object will not be mapped at all -- the returned array will contain
  # only the names of the named objects.
  # 
  def names option=nil
    return map &:name if option.nil?                 # unnamed --> nil
    return map { |e| e.name || e } if option == true # unnamed --> instance
    return map( &:name ).compact if option == false  # unnamed squeezed out
    fail ArgumentError, "Unknown option: #{option}"
  end
end
