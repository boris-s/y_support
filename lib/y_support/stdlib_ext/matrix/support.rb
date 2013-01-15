#encoding: utf-8
require 'matrix'

class Matrix
end

class Vector
  # .zero class method returns a vector filled with zeros
  # 
  def zero( vector_size )
    self[*([0] * vector_size)] # FIXME: Ordinary zero
  end
end
