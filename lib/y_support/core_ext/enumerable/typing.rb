# -*- coding: utf-8 -*-
class Module
  # Fails unless all the collection member comply
  def aE_all( what_is_receiver = "collection" )
    raise AE, "#{what_is_receiver} must all comply" unless
      all? {|e| yield e }
    return self end
  alias :a℈_all :aE_all if USE_SCRUPLE
  
  def aE_all_kind_of( mod, what_is_receiver = "collection" )
    raise AE, "#{what_is_receiver} must all be #kind_of? #{mod}:#{mod.class}" if
      not all? {|e| e.kind_of? mod }
    return self end
  alias :a℈_all_kind_of :aE_all_kind_of if USE_SCRUPLE
  alias :a℈_all_a :a℈_all_kind_of
  
  def aE_all_module_comply( mod, what_is_receiver = "collection" )
    raise AE, "#{what_is_receiver} must all module-comply to #{mod}" unless
      all? {|e| e.declares_module_compliance? mod }
    return self end
  alias :a℈_all_module_comply :aE_all_module_comply if USE_SCRUPLE
  alias :aE_all_ɱ_comply :aE_all_module_comply
  alias :a℈_all_ɱ_comply :aE_all_module_comply if USE_SCRUPLE
  alias :aE_all_∈ :aE_all_module_comply
  alias :a℈_all_∈ :aE_all_module_comply if USE_SCRUPLE
  alias :aE_all_E :aE_all_module_comply
  alias :a℈_all_E :aE_all_module_comply if USE_SCRUPLE
  
  # Fails unless the collection members are #all_numeric?
  def aE_all_numeric( what_is_receiver = "collection" )
    raise AE, "#{what_is_receiver} must be all numeric" unless
      all? {|e| e.kind_of? Numeric }
    return self end
  alias :a℈_all_numeric :aE_all_numeric if USE_SCRUPLE
  
  # Fails unless the collection is a subset of the argument
  def aE_subset_of( other, what_is_receiver = "collection",
                    what_is_argument = "the other collection" )
    unless all? {|e| other.include? e }
      msg = "#{what_is_receiver} must be a subset of #{what_is_argument}"
      raise AE, msg
    end
    return self end
  alias :a℈_subset_of :aE_subset_of if USE_SCRUPLE
  alias :aE_⊂ :aE_subset_of
  alias :a℈_⊂ :aE_subset_of if USE_SCRUPLE
end
