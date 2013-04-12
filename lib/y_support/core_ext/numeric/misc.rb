#encoding: utf-8

class << Integer
  def zero; 0 end
end

class << Float
  def zero; 0.0 end
end

class << Complex
  def zero; Complex 0, 0 end
end
