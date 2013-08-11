#encoding: utf-8

require 'active_support/core_ext/hash/reverse_merge'

class Hash
  # reversed merge!: defaults.merge( self! )
  alias :default! :reverse_merge!
  
  # Applies a block as a mapping on all keys, returning a new hash.
  # 
  def with_keys
    keys.each_with_object self.class.new do |hash_key, hsh|
      hsh[ yield hash_key ] = self[ hash_key ]
    end
  end
  
  # The difference from #with_keys is that modify_keys expects block that takes
  # 2 arguments (key: value pair) and returns the new key.
  # 
  def modify_keys
    each_with_object self.class.new do |hash_pair, hsh|
      hsh[ yield( hash_pair ) ] = self[ hash_pair[0] ]
    end
  end
  
  # Applies a block as a mapping on all values, returning a new hash.
  # 
  def with_values
    each_with_object self.class.new do |(k, v), hsh| hsh[ k ] = yield v end
  end
  
  # Like #do_with_values, but modifies the receiver.
  # 
  def with_values!
    each_with_object self do |(k, v), hsh| hsh[ k ] = yield v end
  end
  
  # The difference from #do_with_values is that modify_values expects block
  # that takes 2 arguments (key: value pair) and returns the new value.
  # 
  def modify_values
    each_with_object self.class.new do |hash_pair, ꜧ|
      ꜧ[ hash_pair[0] ] = yield( hash_pair )
    end
  end
  
  # Like #modify_values, but modifies the receiver.
  # 
  def modify_values!
    each_with_object self do |hash_pair, ꜧ|
      ꜧ[ hash_pair[0] ] = yield( hash_pair )
    end
  end
  
  # Like #map that returns a hash.
  # 
  def modify
    each_with_object self.class.new do |hash_pair, ꜧ|
      key, val = yield hash_pair
      ꜧ[key] = val
    end
  end

  # A bit like Array#slice, but only takes 1 argument, which is either a Range,
  # or an Array, and returns the selection of the hash for the keys that match
  # the range or are present in the array. 
  # 
  def slice matcher
    case matcher
    when Array then select { |key, _| matcher.include? key }
    else self.class[ select { |key, _| matcher === key } ] end
  end
  
  # Makes hash keys accessible as methods. If the hash keys collide with
  # its methods, ArgumentError is raised, unless :overwrite_methods
  # option == true.
  # 
  def dot! overwrite_methods: false
    keys.each do |key|
      msg = "key #{key} of #dot!-ted hash is not convertible to a symbol"
      fail ArgumentError, msg unless key.respond_to? :to_sym
      msg = "#dot!-ted hash must not have key names colliding with its methods"
      fail ArgumentError, msg if methods.include? key.to_sym unless
        overwrite_methods
      define_singleton_method key.to_sym do self[key] end
      define_singleton_method "#{key}=".to_sym do |value| self[key] = value end
    end
    return self
  end

  # Pretty-prints the hash consisting of names as keys, and numeric values.
  # Takes 2 named arguments: +:gap+ and +:precision+.
  # 
  def pretty_print_numeric_values gap: 0, precision: 2
    lmax = keys.map( &:to_s ).map( &:size ).max
    rmax = values.map { |n| "%.#{precision}e" % n }
      .map( &:to_s ).map( &:size ).max
    lgap = gap / 2
    rgap = gap - lgap
    map do |key, val|
      "%- #{lmax+lgap+1}s%#{rmax+rgap+1}.#{precision}e" % [ key, val ]
    end.each &:puts
    return nil
  end
end
