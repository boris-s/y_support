# -*- coding: utf-8 -*-
class Object
  def const_set_if_not_defined( const, value )
    mod = self.is_a?(Module) ? self : self.singleton_class
    mod.const_set( const, value ) unless mod.const_defined?( const )
  end
  alias :const_set_if_not_dϝ :const_set_if_not_defined
  
  def const_redef_without_warning( const, value )
    mod = self.is_a?(Module) ? self : self.singleton_class
    mod.send(:remove_const, const) if mod.const_defined?( const )
    mod.const_set( const, value )
  end
  alias :const_redϝ_wo_warning :const_redef_without_warning
  
  def null_object?( what = nil )
    is_a?( NullObject ) and  what.nil? ? true : self.what == what
  end
  alias :null? :null_object?
  
  # Converts #nil?-positive objects to NullObjects. If 2 arguments
  # are given, then first is considered what object type descriptor,
  # and second object to judge.
  def Maybe(a1, a2 = ℒ)
    if a2.ℓ? then value = a1 else what, value = a1, a2 end
    if value.nil? then NullObject.new what else value end
  end
  
  # NullObject constructor
  def Null( what=nil ); NullObject.new what end
  
  # InertRecorder constructor
  def InertRecorder *aj, &b; InertRecorder.new *aj, &b end
  
  # LocalObject constructor
  def LocalObject signature = nil; LocalObject.new signature end
  alias :ℒ :LocalObject
  
  # #local_object? inquirer
  def local_object? s = nil; is_a? LocalObject and signature == s end
  alias :ℓ? :local_object?
  
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
