#encoding: utf-8

class Enumerable
  # Fails with ArgumentError unless all the collection member comply
  # with the supplied block (true/false output).
  # 
  def aE_all( what_is_receiver_txt = "collection" )
    raise AE, "#{what_is_receiver_txt} must all comply" unless
      all? {|e| yield e }
    return self
  end

  # Fails with ArgumentError unless all collection members are #kind_of?
  # 
  def aE_all_kind_of( kind, what_is_receiver_txt = "collection" )
    raise AE, "#{what_is_receiver txt} must all be #kind_of? " +
      "#{mod}:#{mod.class}" if any? {|e| ! e.kind_of? kind }
    return self
  end
  alias :aE_all_a :aE_all_kind_of

  # Fails with ArgumentError unless all collection members declare class
  # compliance with specified class/module.
  # 
  def aE_all_declare_kind_of( kind, what_is_receiver_txt = "collection" )
    raise AE, "#{what_is_receiver_txt} must all module-comply to #{mod}" unless
      all? {|e| e.declares_module_compliance? kind }
    return self
  end
  alias :aE_all_declare_class :aE_all_declare_kind_of
  alias :aE_all_declare_ç :aE_all_declare_kind_of
  
  # Fails unless the collection members all declare compliance with Numeric.
  # 
  def aE_all_numeric( what_is_receiver_txt = "collection" )
    raise AE, "#{what_is_receiver_txt} must be all numeric" unless
      all? {|e| e.kind_of? Numeric }
    return self
  end
  
  # Fails unless the collection is a subset of the argument.
  # 
  def aE_subset_of other_collection,
                   what_is_receiver_txt = "collection",
                   what_is_other_collection_txt = "the required collection"
    raise AE, "#{what_is_receiver_txt} must be a subset of " +
      "#{what_is_other_collection_txt}" unless all? {|e| other.include? e }
    return self
  end
  alias :aE_⊂ :aE_subset_of
end
