#encoding: utf-8

class Hash
  # Merges the synonymous hash keys into a single main key - useful for
  # argument passing and validation.  Returns nil if neither main key,
  # nor synonyms were found. Returns false (no merging) if the main key
  # was found, but no synonym keys. Returns true (yes merging) if any of
  # the synonym keys is found and renamed/merged to the main key. Value
  # collisions in synonym keys (detected by #==) raise ArgumentError.
  def merge_synonym_keys!( key, *synonyms )
    synonyms.reduce has_key?( key ) ? false : nil do |acc, syn|
      next acc unless has_key? syn
      if acc.nil? then self[key] = self[syn]; delete syn; next true end
      if self[key] == self[syn] then delete syn; next true else
        raise AE, "Value collision in syn. key #{syn}!" end
    end
  end
  
  # Convenience wrapper around #merge_synonym_keys!. Returns true if
  # either main key or any synonyms were found, false otherwise.
  def may_have key, oo = {}
    merge_synonym_keys!( key, *oo[:syn!] ).nil?
    return self[key]
  end
  
  def has? key, oo = {}; !merge_synonym_keys!( key, *oo[:syn!] ).nil? end
  alias :∋? :has?
  
  # This enforcer method raises ArgumentError when:
  # 1. Neither supplied key nor any synonyms are present.
  # 2. The supplied block, if any, returns false with the valuen
  # The return value of this method is the value of the supplied key.
  def aE_has key, oo = {}
    raise AE, "Key absent: '#{key}'" unless self.∋? key, oo
    # Now validate self[key] using the supplied block
    raise AE, "Value rejected for key: #{key}" unless
      yield self[key] if block_given?
    return self[key] end
  alias :must_have :aE_has
  alias :a℈_has :aE_has if ::YSupport::USE_SCRUPLE
  alias :aE_∋ :aE_has
  alias :a℈_∋ :aE_has if ::YSupport::USE_SCRUPLE
end
