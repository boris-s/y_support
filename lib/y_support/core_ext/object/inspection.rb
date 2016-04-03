class Object
  # Constructs the string "#{self.class}:#{self}". Useful for inspection.
  # 
  def y_inspect( option=nil )
    case option
    when :full then "#<#{y_inspect}>"
    when :short then
      "#{self.class.name.to_s.split( "::" ).last}:#{self}"
    else
      "#{self.class}:#{self}"
    end
  end
end
