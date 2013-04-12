# -*- coding: utf-8 -*-

class Object
  def const_set_if_not_defined( const, value )
    mod = self.is_a?(Module) ? self : self.singleton_class
    mod.const_set( const, value ) unless mod.const_defined?( const )
  end

  def const_redefine_without_warning( const, value )
    mod = self.is_a?(Module) ? self : self.singleton_class
    mod.send(:remove_const, const) if mod.const_defined?( const )
    mod.const_set( const, value )
  end

  # RespondTo constructor
  def RespondTo method; RespondTo.create method end

  # Create public attributes (ie. with readers) and initialize them with
  # prescribed values. Takes a hash of { symbol => value } pairs. Existing methods
  # are not overwritten by the new getters, unless option :overwrite_methods
  # is set to true.
  def singleton_set_attr_with_readers( hash, oo = {} )
    hash.each { |key, val|
      key = key.aE_respond_to( :to_sym, "key of the attr hash" ).to_sym
      instance_variable_set( "@#{key}", val )
      if oo[:overwrite_methods] then ⓒ.module_exec { attr_reader key }
      elsif methods.include? key
        raise "Attempt to add \##{key} getter failed: " +
          "method \##{key} already defined."
      else ⓒ.module_exec { attr_reader key } end
    }
  end
  alias :ⓒ_set_attr_w_readers :singleton_set_attr_with_readers
end
