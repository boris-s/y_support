#encoding: utf-8

class Hash
  # Merges the synonymous hash keys into a single key - useful for argument
  # validation. Returns nil if neither main key, nor synonyms are found.
  # Returns false (no merging) if the main key was found, but no synonym keys.
  # Returns true (yes merging) if any of the synonym keys is found and
  # renamed/merged to the main key. Value collisions in synonym keys (detected
  # by #==) raise ArgumentError.
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
        raise TErr, "Value collision between #{key} and its synonym #{syn}!"
      end
    end
  end
  
  # This method uses #merge_synonym_keys! method first and then returns the
  # value under the key. The first argument is the main key. Synonyms may be
  # supplied as a named argument :syn!. (Bang indicates that the synonym keys
  # will be merged with the main key, modifying the hash.)
  # 
  def may_have key, options={}
    merge_synonym_keys!( key, *options[:syn!] ).nil?
    return self[key]
  end

  # This method behaves similarly to #may_have, with the difference that it
  # does not return the value of the key, only true / false to indicate whether
  # the key or any synonym has been found.
  # 
  def has? key, options={}
    !merge_synonym_keys!( key, *options[:syn!] ).nil?
  end
  
  # This enforcer method (aka. runtime assertion) raises TypeError when:
  # 1. Neither the required key nor any of its synonyms are present.
  # 2. The supplied criterion block, if any, returns false when applied
  # to the value of the key in question. If the block takes an argument
  # (or more arguments), the value is passed in. If the block takes no
  # arguments (arity 0), it is executed inside the singleton class of the
  # receiver (using #instance_exec method).
  # 
  def aT_has key, options={}, &b
    raise TErr, "Key '#{key}' absent!" unless has? key, options
    # Now validate self[key] using the supplied block
    if block_given?
      m = "Value for #{key} fails its duck type!"
      raise TErr, m unless ( b.arity == 0 ? self[key].instance_exec( &b ) :
                               b.( self[key] ) )
    end
    return self[key]
  end
  alias :must_have :aT_has

  # This method behaves exactly like #aT_has, but with the difference, that
  # it raises ArgumentError instead of TypeError
  # 
  def aE_has key, options={}, &b
    begin
      options.empty? ? aT_has( key, &b ) : aT_has( key, options, &b )
    rescue TypeError => e
      raise AErr, e.message
    end
  end
end
