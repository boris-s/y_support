# encoding: utf-8

require 'active_support/core_ext/hash/reverse_merge'

class Hash
  class << self
    # This kluge method guards against overwriting of the #slice method by
    # ActiveSupport.
    # 
    def method_added( sym )
      if sym == :slice then
        # Unless it is our method, overwrite it.
        unless instance_method( sym ).source_location.include? 'y_support'
          # Let's now make a cache of this very method being called
          ma = singleton_class.instance_method :method_added
          # Let's remove the :method_added hook, or otherwise infinite recursion
          # would ensue.
          singleton_class.class_exec { remove_method :method_added }
          # And let's redefine the +:slice+ method now:
          warn "Warning: Attempt to redefine Hash##{sym} occured, reverting." if YSupport::DEBUG

          class_exec do
            # A bit like Array#slice, but only takes 1 argument, which is either
            # a Range, or an Array, and returns the selection of the hash for
            # the keys that match the range or are present in the array.
            # 
            define_method sym do |matcher|
              self.class[ case matcher
                          when Array then
                            select { |key, _| matcher.include? key }
                          else
                            select { |key, _| matcher === key }
                          end ]
            end
          end

          # Finally, let's bind the +:method_added+ method to self again.
          singleton_class.class_exec do
            define_method :method_added do |sym| ma.bind( self ).call( sym ) end
          end
        end
      end
    end
  end

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

  # Checking mainly against the collision with ActiveSupport's Hash#slice.
  if Hash.instance_methods.include? :slice then
    warn "Collision: Method #slice already defined on Hash! (%s)" %
      Hash.instance_method( :slice ).source_location
  end

  # A bit like Array#slice, but only takes 1 argument, which is either a Range,
  # or an Array, and returns the selection of the hash for the keys that match
  # the range or are present in the array.
  # 
  def slice matcher
    self.class[ case matcher
                when Array then
                  select { |key, _| matcher.include? key }
                else
                  select { |key, _| matcher === key }
                end ]
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
    key_strings = keys.map &:to_s
    value_strings = values.map do |n| "%.#{precision}e" % n rescue "%s" % s end
    lmax, rmax = key_strings.map( &:size ).max, values_strings.map( &:size ).max
    lgap = gap / 2
    rgap = gap - lgap
    key_strings.zip( value_strings ).map do |kς, vς|
      "%- #{lmax+lgap+1}s%#{rmax+rgap+1}.#{precision}e" % [ kς, vς ]
    end.each { |line| puts line }
    return nil
  end
end
