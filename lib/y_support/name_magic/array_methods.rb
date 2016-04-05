# encoding: utf-8

module NameMagic::ArrayMethods
  # Maps an array of some objects into an array of their names,
  # obtained by applying +#full_name+ method to them. Takes one
  # optional argument, which regulates its behavior regarding
  # unnamed objects. If set to _nil_ (default), unnamed objects
  # will be mapped to _nil_ (default behavior of the +#name+
  # method).  If set to _true_, unnamed objects will be mapped to
  # themselves. If set to _false_, unnamed objects will not be
  # mapped at all -- the returned array will contain only the names
  # of the named objects.
  # 
  def names option=nil
    # unnamed --> nil
    return map &:name if option.nil?
    # unnamed --> instance
    return map { |e| e.name || e } if option == true
    # unnamed squeezed out
    return map( &:name ).compact if option == false
    fail ArgumentError, "Unknown option: #{option}"
  end
  # FIXME: The remaining thing to do to achieve compatibility with
  # Ruby's #name is to put "full_name" in the body, and "name" in
  # the alias...
  alias full_names names

  # Maps an array to an array of the element names, obtained by
  # applying +#_name_+ method to them. Takes one optional argument,
  # which regulates its behavior regarding unnamed objects. If set
  # to _nil_ (default) unnamed objects will be mapped to _nil_
  # (default behavior of +#_name_+ method). If set to _true_,
  # unnamed objects will be mapped to themselves. If set to
  # _false_, unnamed objects will not be mapped at all -- the
  # returned array will contain only the names of the named
  # objects.
  # 
  def _names_ option=nil
    # unnamed --> nil
    return map &:_name_ if option.nil?
    # unnamed --> instance
    return map { |e| e.name || e } if option == true
    # unnamed squeezed out
    return map( &:_name_ ).compact if option == false
    fail ArgumentError, "Unknown option: #{option}"
  end
  alias ɴs _names_
end
