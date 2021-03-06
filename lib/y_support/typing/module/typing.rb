class Module
  # === Support for typing by declaration

  # Compliance inquirer (declared compliance + ancestors).
  # 
  def complies?( other_module )
    compliance.include? other_module.aT_kind_of( Module, "other module" )
  end

  # Declared compliance inquirer.
  # 
  def declares_compliance?( other_module )
    other_module.aT_kind_of Module, "other module"
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

  # Using this method, the receiver explicitly declares that its interface
  # complies with another module (class).
  # 
  def declare_compliance! other_module
    other_module.aT_kind_of Module, "other module"
    return false if declared_compliance.include? other_module
    ( @declared_compliance ||= [] ) << other_module
    return true
  end
end
