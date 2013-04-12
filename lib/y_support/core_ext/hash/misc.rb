#encoding: utf-8

class Hash
  # reversed merge!: defaults.merge( self! )
  alias :default! :reverse_merge!
  
  # Applies a block as a mapping on all keys, returning a new hash
  def with_keys
    keys.each_with_object ç.new do |hash_key, ꜧ|
      ꜧ[ yield( hash_key ) ] = self[ hash_key ]
    end
  end
  alias :do_with_keys :with_keys
  
  # The difference from do_with_keys is that modify_keys expects block
  # that takes 2 arguments (key: value pair) and returns the new key.
  def modify_keys
    each_with_object ç.new do |hash_pair, ꜧ|
      ꜧ[ yield( hash_pair ) ] = self[ hash_pair[0] ]
    end
  end
  
  # Applies a block as a mapping on all values, returning a new hash
  def with_values
    each_with_object ç.new do |hash_pair, ꜧ|
      ꜧ[ hash_pair[0] ] = yield( hash_pair[1] )
    end
  end
  alias :do_with_values :with_values
  
  # Like #do_with_values, but modifies the receiver.
  def with_values!
    each_with_object self do |hash_pair, ꜧ|
      hash_key, hash_val = hash_pair
      ꜧ[ hash_key ] = yield( hash_val )
    end
  end
  alias :do_with_values! :with_values!
  
  # The difference from #do_with_values is that modify_values expects block
  # that takes 2 arguments (key: value pair) and returns the new value.
  def modify_values
    each_with_object ç.new do |hash_pair, ꜧ|
      ꜧ[ hash_pair[0] ] = yield( hash_pair )
    end
  end
  
  # Like #modify_values, but modifies the receiver
  def modify_values!
    each_with_object self do |hash_pair, ꜧ|
      ꜧ[ hash_pair[0] ] = yield( hash_pair )
    end
  end
  
  # Like #map that returns a hash.
  def modify
    each_with_object ç.new do |hash_pair, ꜧ|
      key, val = yield hash_pair
      ꜧ[key] = val
    end
  end
  
  # Makes hash keys accessible as methods. If the hash keys collide with
  # its methods, ArgumentError is raised, unless :overwrite_methods
  # option == true.
  # 
  def dot!( oo = {} )
    keys.each do |key|
      msg = "key #{key} of #dot!-ted hash is not convertible to a symbol"
      raise ArgumentError, msg unless key.respond_to? :to_sym
      unless oo[:overwrite_methods]
        if methods.include? key.to_sym
          raise ArgumentError, "#dot!-ted hash must not have key names " +
            "colliding with its methods"
        end
      end
      
      define_singleton_method key.to_sym do
        self[key]
      end
      
      define_singleton_method "#{key}=".to_sym do |value|
        self[key] = value
      end
    end
    return self
  end
end
