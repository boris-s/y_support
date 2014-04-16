class Hash
  # Merges the synonymous hash keys into a single key - useful for argument
  # validation. Returns nil if neither main key, nor synonyms are found.
  # Returns false (no merging) if the main key was found, but no synonym keys.
  # Returns true (yes merging) if any of the synonym keys is found and
  # renamed/merged to the main key. Value collisions in synonym keys (detected
  # by +#==+) raise +ArgumentError+.
  # 
  def merge_synonym_keys!( key, *synonyms )
    synonyms.reduce has_key?( key ) ? false : nil do |acc, syn|
      next acc unless has_key? syn
      if acc.nil? then
        self[key] = self[syn]
        delete syn
        next true
      end
      if self[key] == self[syn] then
        delete syn
        next true
      else
        raise TypeError, "Value collision between #{key} and its synonym #{syn}!"
      end
    end
  end
  
  # Calls +#merge_synonym_keys!+ first, then returns the value under the
  # specified key. The first argument is the main key, synonym keys may be
  # supplied as a named argument +:syn!+. (Bang indicates that the synonym
  # keys will be merged with the main key, thus modifying the hash.)
  # 
  def may_have key, options={}
    merge_synonym_keys!( key, *options[:syn!] ).nil?
    return self[key]
  end

  # This method behaves like +#may_have+, but it returns _true_/_false_ value
  # instead of the value under the specified key.
  # 
  def has? key, options={}
    ! merge_synonym_keys!( key, *options[:syn!] ).nil?
  end

  # This runtime assertion raises +TypeError+ when:
  # 1. Neither the required key nor any of its synonyms are present.
  # 2. The supplied criterion block, if any, returns false when applied
  # to the value of the key in question. If the block takes an argument
  # (or more arguments), the value is passed in. If the block takes no
  # arguments (arity 0), it is executed inside the singleton class of the
  # receiver (using +#instance_exec+ method).
  # 
  def aT_has key, options={}, &b
    fail TypeError, "Key '#{key}' absent!" unless has? key, options
    self[key].tap do |val|
      fail TypeError, "Value for #{key} of wrong type!" unless
        ( b.arity == 0 ? val.instance_exec( &b ) : b.( val ) ) if b
    end
  end
  alias :must_have :aT_has

  # This method behaves exactly like +#aT_has+, but it raises +ArgumentError+
  # instead of +TypeError+.
  # 
  def aA_has key, options={}, &b
    fail ArgumentError, "Key '#{key}' absent!" unless has? key, options
    self[key].tap do |val|
      fail ArgumentError, "Value for #{key} of wrong type!" unless
        ( b.arity == 0 ? val.instance_exec( &b ) : b.( val ) ) if b
    end
  end

  # Fails with +TypeError+ unless the receiver's +#empty?+ returns _true_.
  # 
  def aT_empty what_is_receiver="hash"
    tap { empty? or fail TypeError, "%s not empty".X!( what_is_receiver ) }
  end

  # Fails with +TypeError+ unless the receiver's `#empty?` returns _false_.
  # 
  def aT_not_empty what_is_receiver="hash"
    tap { empty? and fail TypeError, "%s empty".X!( what_is_receiver ) }
  end

  # Fails with +ArgumentError+ unless the receiver's `#empty?` returns _true_.
  # 
  def aA_empty what_is_receiver="hash"
    tap { empty? or fail ArgumentError, "%s not empty".X!( what_is_receiver ) }
  end

  # Fails with +ArgumentError+ unless the receiver's `#empty?` returns _false_.
  # 
  def aA_not_empty what_is_receiver="hash"
    tap { empty? and fail ArgumentError, "%s empty".X!( what_is_receiver ) }
  end
end
