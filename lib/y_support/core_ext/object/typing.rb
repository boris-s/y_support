# -*- coding: utf-8 -*-
class Object
  # Alias for ArgumentError
  AE = ArgumentError

  # Class compliance inquirer.
  def declares_module_compliance?( mod )
    if mod.is_a? Module then mod = mod.name else mod = mod.to_s end
    if self.class.name == mod then return true # native type
    elsif module_compliance.include?( mod ) then return true # expl. declared compliance
    elsif begin
            self.singleton_class
          rescue TypeError
            self.class
          end.ancestors.any? {|ancest| ancest.name == mod } then
      return true # implicit compliance through ancestry
    else return false end # none applies
  end
  alias :declares_ɱ_compliance? :declares_module_compliance?
  alias :E? :declares_module_compliance?
  alias :∈? :declares_module_compliance?
  
  # Class compliance pseudo-getter.
  def module_compliance
    mods = instance_variable_get :@module_compliance
    return [ self.class.name ] if mods.nil?
    raise "Unexpected @module_compliance instance variable. Name collision?" if
      not ( mods.is_a?( Array ) and mods.include?( self.class.name ) )
    return mods
  end
  alias :ɱ_compliance :module_compliance
  
  # Declaration of class compliance.
  def declare_module_compliance!( *syms_or_mods )
    syms_or_mods.each { |sym_or_mod|
      if sym_or_mod.is_a? Module then names = sym_or_mod.ancestors.map &:ɴ
      else names = [ sym_or_mod.to_s ] end
      instance_variable_set :@module_compliance, ( module_compliance + names ).uniq
    }
  end
  alias :declare_ɱ_compliance! :declare_module_compliance!
  alias :∈! :declare_module_compliance!

  # DUCK TYPING SUPPORT

  
  # Fails unless the receiver fulfills the criterion supplied in a block.
  def aE( how_comply = "comply", what_is_receiver = "object", &b )
    if block_given?
      raise AE, "#{what_is_receiver} fails to #{how_comply}" unless
        ( b.arity != 0 ) ? b.( self ) : self.instance_exec( &b )
    else
      raise AE, "#{what_is_receiver} fails to be truey" unless self
    end
    return self
  end
  
  # Fails if the receiver fulfills the criterion supplied in a block.
  def aE_not( how_comply = "comply", what_is_receiver = "object", &b )
    if block_given?
      raise AE, "#{what_is_receiver} must not #{how_comply}" if
        ( b.arity != 0 ) ? b.( self ) : self.instance_exec( &b )
    else
      raise AE, "#{what_is_receiver} fails to be falsey" if self
    end
    return self
  end
  
  # Fails unless the receiver complies
  def aE_kind_of( ç, what_is_receiver = "object" )
    raise AE, "#{what_is_receiver} is not a kind of #{ç}" unless
      self.kind_of? ç
    return self end
  alias :aE_is_a :aE_kind_of
  
  # Fails unless the receiver complies
  def aE_module_compliance( ɱ, what_is_receiver = "object" )
    raise AE, "#{what_is_receiver} declares not compliance to :#{ɱ}" unless
      self.∈? ɱ
    return self end
  alias :aE_ɱ_compliance :aE_module_compliance
  alias :aE_∈ :aE_module_compliance
  
  # Fails unless the receiver complies
  def aE_respond_to( mt_sym, what_is_receiver = "object" )
    raise AE, "#{what_is_receiver} responds not to \##{mt_sym}" unless
      self.respond_to? mt_sym.to_sym
    return self
  end
  
  # Fails unless the receiver complies
  def aE_equal( other, what_is_receiver = "object",
                what_is_other = "the prescribed value" )
    raise AE, "#{what_is_receiver} not == to #{what_is_other}" unless
      self == other
    return self
  end
  
  # Fails unless the receiver complies
  def aE_not_equal( other, what_is_receiver = "object",
                    what_is_other = "the prescribed value")
    raise AE, "#{what_is_receiver} must not == to #{what_is_other}" if
      self == other
    return self
  end
  
  # Fails unless the receiver complies
  def aE_blank( what_is_receiver = "object" )
    raise AE, "#{what_is_receiver} must be \#blank?" unless self.blank?
    return self
  end
  
  # Fails unless the receiver complies
  def aE_not_blank( what_is_receiver = "object" )
    raise AE, "#{what_is_receiver} must not be \#blank?" if self.blank?
    return self
  end
  
  # Fails unless the receiver complies
  def aE_present( what_is_receiver = "object" )
    raise AE, "#{what_is_receiver} must be \#present?" unless self.present?
    return self
  end
  
  # Fails unless the receiver has prescribed attribute reader
  def aE_has_attr_reader( y, what_is_receiver = "object" )
    m = begin
          send y
        rescue NoMethodError
          raise AE, "#{what_is_receiver} must have attr_reader #{y}"
        end
    begin
      instance_variable_set( "@#{y}", "very unusual value indeed" )
      raise AE, "#{what_is_receiver} must have attr_reader #{y}" unless
        send(y) == "very unusual value indeed"
    ensure
      instance_variable_set "@#{y}", m
    end
    return self
  end
end
