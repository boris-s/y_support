class Object
  # Constructs the string "#{self.class}:#{self}". Useful for inspection.
  # 
  def insp
    "#{self}:#{self.class}"
  end
end
