#encoding: utf-8

module Enumerable
  # Fails with TypeError unless all the members of the collection comply with
  # the supplied block criterion. Optional arguments customize the error
  # message. First optional argument describes the collection element, the
  # second one describes the tested duck type. If the criterion block takes
  # at least one argument, the receiver elemnts are passed to it (#all?
  # method). If the criterion block takes no arguments (arity 0), it is
  # gradually executed inside the elements (using #instance_exec method).
  # If no block is given, all members are required to be truey.
  # 
  def aT_all what_is_collection_element=nil, how_comply=nil, &b
    e = what_is_collection_element || "collection element"
    if block_given?
      m = "Each #{e} must %s!" %
        ( how_comply ? how_comply : "comply with the given duck type" )
      raise TErr, m unless ( b.arity == 0 ?
                             all? { |e| e.instance_exec( &b ) } :
                             all? { |e| b.( e ) } )
    else
      m = "No #{e} must be nil or false!"
      raise TErr, m unless all? { |e| e }
    end
    return self
  end

  # Fails with TypeError unless all collection members are #kind_of? the
  # class supplied as argument. Second optional argument (collection element
  # description) customizes the error message.
  # 
  def aT_all_kind_of klass, what_is_collection_element=nil
    e = what_is_collection_element || "collection element"
    m = "Each #{e} must be kind of #{klass}!"
    raise TErr, m unless all? { |e| e.kind_of? klass }
    return self
  end

  # Fails with TypeError unless all collection members declare compliance with
  # compliance with the class supplied as argument. Second optional argument
  # (collection element description) customizes the error message.
  # 
  def aT_all_comply klass, what_is_collection_element=nil
    e = what_is_collection_element || "collection element"
    m = "Each #{e} must declare compliance to #{klass}!"
    raise TErr, m unless all? { |e| e.class_complies? klass }
    return self
  end
  
  # Fails with TypeError unless all the collection members declare compliance
  # with Numeric. Second optional argument (collection element description)
  # customizes the error message.
  # 
  def aT_all_numeric what_is_collection_element=nil
    e = what_is_collection_element || "collection element"
    m = "Each #{e} must declare compliance with Numeric!"
    raise TErr, m unless all? { |e| e.class_complies? Numeric }
    return self
  end
  
  # Fails with TypeError unless all the collection members are included int the
  # collection supplied as argument. Second optional argument (collection
  # element description) customizes the error message.
  # 
  def aT_subset_of other_collection, what_is_receiver_collection=nil,
                   what_is_other_collection=nil
    rc = what_is_receiver_collection ?
      what_is_receiver_collection.to_s.capitalize : "collection"
    oc = what_is_other_collection ? what_is_other_collection.to_s.capitalize :
      "the specified collection"
    m = "The #{rc} must be a subset of #{oc}"
    raise TErr, m unless all? { |e| other_collection.include? e }
    return self
  end
end
