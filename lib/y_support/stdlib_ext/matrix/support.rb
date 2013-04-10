#encoding: utf-8
require 'matrix'

class Matrix
  # Pretty inspect
  def pretty_inspect
    return inspect if row_size == 0 or column_size == 0
    aa = send(:rows).each.with_object [] do |row, memo|
      memo << row.map{ |o|
        os = o.to_s
        case o
        when Numeric then os[0] == '-' ? os : ' ' + os
        else o.to_s end
      }
    end
    width = aa.map{ |row| row.map( &:size ).max }.max + 1
    aa.each_with_object "" do |row, memo|
      row.each{ |e| memo << e << ' ' * ( width - e.size ) }
      memo << "\n"
    end
  end
  
  # Pretty print
  def pretty_print
    print pretty_inspect
    return nil
  end
  alias :pp :pretty_print
  
  # Given two arrays, creates correspondence matrix, with no. of cols
  # equal to the 1st array, and no. of rows to the 2nd. This matrix can
  # be used eg. for conversion between column vectors corresponding to
  # the 1st and 2nd array:
  #
  # Matrix.correspondence_matrix( array1, array2 ) * col_vector_1
  # #=> col_vector_2
  # 
  def self.correspondence_matrix( array1, array2 )
    return Matrix.empty 0, array1.size if array2.empty?
    return Matrix.empty array2.size, 0 if array1.empty?
    self[ *array2.map { |e2| array1.map { |e1| e1 == e2 ? 1 : 0 } } ] # FIXME: Ordinary zero
  end
  
  # Converts a column into array. If argument is given, it chooses
  # column number, otherwise column 0 is assumed.
  # 
  def column_to_a n=0; ( col = column( n ) ) ? col.to_a : nil end
  
  # Converts a row into array. If argument is given, it chooses row
  # number, otherwise row 0 is assumed.
  # 
  def row_to_a n=0; ( r = row( n ) ) ? r.to_a : nil end
  
  # Shorter aliases for #row_vector, #column_vector
  # 
  def self.cv *aa, &b; column_vector *aa, &b end
  def self.rv *aa, &b; row_vector *aa, &b end
  
  #join_bottom method
  #
  def join_bottom other;
    raise ArgumentError, "Column size mismatch" unless
      column_size == other.column_size
    return other.map { |e| e } if row_size == 0
    return Matrix.empty row_size + other.row_size, 0 if column_size == 0
    ç[ *( row_vectors + other.row_vectors ) ]
  end
  
  #join_right methods
  #
  def join_right other;
    raise ArgumentError, "Row size mismatch" unless row_size == other.row_size
    ( t.join_bottom( other.t ) ).t
  end

  # aliasing #row_size, #column_size
  alias :number_of_rows :row_size
  alias :number_of_columns :column_size
  alias :height :number_of_rows
  alias :width :number_of_columns

  #
  # Creates a empty matrix of +row_size+ x +column_size+.
  # At least one of +row_size+ or +column_size+ must be 0.
  #
  #   m = Matrix.empty(2, 0)
  #   m == Matrix[ [], [] ]
  #     => true
  #   n = Matrix.empty(0, 3)
  #   n == Matrix.columns([ [], [], [] ])
  #     => true
  #   m * n
  #     => Matrix[[0, 0, 0], [0, 0, 0]]
  #
  def Matrix.empty(row_size = 0, column_size = 0)
    Matrix.Raise ArgumentError, "One size must be 0" if column_size != 0 && row_size != 0
    Matrix.Raise ArgumentError, "Negative size" if column_size < 0 || row_size < 0

    new([[]]*row_size, column_size)
  end

  #
  # Creates a matrix of size +row_size+ x +column_size+.
  # It fills the values by calling the given block,
  # passing the current row and column.
  # Returns an enumerator if no block is given.
  #
  #   m = Matrix.build(2, 4) {|row, col| col - row }
  #     => Matrix[[0, 1, 2, 3], [-1, 0, 1, 2]]
  #   m = Matrix.build(3) { rand }
  #     => a 3x3 matrix with random elements
  #
  def Matrix.build(row_size, column_size = row_size)
    row_size = CoercionHelper.coerce_to_int(row_size)
    column_size = CoercionHelper.coerce_to_int(column_size)
    raise ArgumentError if row_size < 0 || column_size < 0
    return to_enum :build, row_size, column_size unless block_given?
    rows = Array.new(row_size) do |i|
      Array.new(column_size) do |j|
        yield i, j
      end
    end
    new rows, column_size
  end
end

class Vector
  # .zero class method returns a vector filled with zeros
  # 
  def zero( vector_size )
    self[*([0] * vector_size)] # FIXME: Ordinary zero
  end
end
