# encoding: utf-8

class Object
  # Constructs the string "#{self.class}:#{self}". Useful for inspection.
  # 
  def insp
    "#{self.class}:#{self}"
  end
end
