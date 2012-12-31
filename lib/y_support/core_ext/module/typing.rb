#encoding: utf-8

class Module
  # === Support for typing by declaration

  # Compliance inquirer (declared compliance + ancestors).
  # 
  def complies?( other_module )
    other_module.tE_kind_of Module, "other module"
    compliance.include? other_module
  end

  # Declared complience inquirer.
  # 
  def declares_compliance?( other_module )
    other_module.tE_kind_of Module, "other module"
    declared_compliance.include? other_module
  end

  # Compliance (declared compliance + ancestors).
  # 
  def compliance
    ( declared_compliance + ancestors ).uniq
  end

  # Declared compliance getter.
  # 
  def declared_compliance
    ( ( @declared_compliance || [] ) + ancestors.map { |a|
        a.instance_variable_get( :@declared_compliance ) || []
      }.reduce( [], :+ ) ).uniq
  end

  # Declaration of module / class compliance.
  # 
  def declare_compliance! other_module
    other_module.tE_kind_of Module, "other module"
    return false if declared_compliance.include? other_module
    ( @declared_compliance ||= [] ) << other_module
    return true
  end
end
