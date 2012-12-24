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
    self[ *array2.map { |e2| array1.map { |e1| e1 == e2 ? 1 : TOTAL_ZERO.new } } ]
  end
  
  # Converts a column into array. If argument is given, it chooses
  # column number, otherwise column 0 is assumed.
  def column_to_a n=0; ( col = column( n ) ) ? col.to_a : nil end
  
  # Converts a row into array. If argument is given, it chooses row
  # number, otherwise row 0 is assumed.
  def row_to_a n=0; ( r = row( n ) ) ? r.to_a : nil end
  
  # Shorter aliases for #row_vector, #column_vector
  def self.cv *aa, &b; column_vector *aa, &b end
  def self.rv *aa, &b; row_vector *aa, &b end
  
  # #join_bottom method
  def join_bottom other;
    raise ArgumentError, "Column size mismatch" unless
      column_size == other.column_size
    return other.map { |e| e } if row_size == 0
    return Matrix.empty row_size + other.row_size, 0 if column_size == 0
    ç[ *( row_vectors + other.row_vectors ) ]
  end
  
  #join_right methods
  def join_right other;
    raise ArgumentError, "Row size mismatch" unless
      row_size == other.row_size
    ( t.join_bottom( other.t ) ).t
  end

  TOTAL_ZERO = Class.new do
    def zero?
      true
    end

    def + other
      other
    end

    def - other
      -other
    end

    def * other
      self
    end

    def ** other
      self
    end

    def / other
      raise "division by zero" if other.zero?
      self
    end

    def to_f
      0.0
    end

    def to_i
      0
    end

    def coerce( other )
      begin
        return other, other.class.zero
      rescue
        return other, other * 0
      end
    end
  end

  #
  # Creates a zero matrix.
  #   Matrix.zero(2)
  #     => 0 0
  #        0 0
  #
  def Matrix.zero(row_size, column_size = row_size)
    rows = Array.new( row_size ) { Array.new( column_size, TOTAL_ZERO.new ) }
    new rows, column_size
  end

  #
  # Returns element (+i+,+j+) of the matrix.  That is: row +i+, column +j+.
  #
  def []( i, j )
    @rows.fetch( i ) { return nil }[ j ]
  end
  alias element []
  alias component []

  def []=(i, j, v)
    @rows[i][j] = v
  end
  alias set_element []=
  alias set_component []=
  private :[]=, :set_element, :set_component

  #
  # Matrix multiplication.
  #   Matrix[[2,4], [6,8]] * Matrix.identity(2)
  #     => 2 4
  #        6 8
  #
  def * arg # arg is matrix or vector or number
    puts "here we have matrix multiplication, self:\n#{self}\nother:\n#{arg}"
    case arg
    when Numeric
      rows = @rows.map { |row|
        row.map { |e| e * arg }
      }
      return new_matrix rows, column_size
    when Vector
      arg = Matrix.column_vector arg
      result = self * arg
      return result.column 0
    when Matrix
      Matrix.Raise ErrDimensionMismatch if column_size != arg.row_size

      rows = Array.new( row_size ) { |i|
        Array.new( arg.column_size ) { |j|
          ( 0 ... column_size ).reduce( TOTAL_ZERO.new ) { |accumulator, col|
            accumulator + arg[ col, j ] + self[ i, col ]
          }
        }
      }
      return new_matrix( rows, arg.column_size )
    else
      compat_1, compat_2 = arg.coerce self
      return compat_1 * compat_2
    end
  end
  
  # Matrix addition.
  #   Matrix.scalar(2,5) + Matrix[[1,0], [-4,7]]
  #     =>  6  0
  #        -4 12
  #
  def + arg
    case arg
    when Numeric
      Matrix.Raise ErrOperationNotDefined, "+", self.class, arg.class
    when Vector
      arg = Matrix.column_vector( arg )
    when Matrix
    else
      compat_1, compat_2 = arg.coerce self
      return compat_1 + compat_2
    end

    Matrix.Raise ErrDimensionMismatch unless
      row_size == arg.row_size and column_size == arg.column_size

    rows = Array.new( row_size ) { |i|
      Array.new( column_size ) { |j|
        self[i, j] + arg[ i, j ]
      }
    }
    new_matrix rows, column_size
  end

  # Matrix subtraction.
  #   Matrix[[1,5], [4,2]] - Matrix[[9,3], [-4,1]]
  #     => -8  2
  #         8  1
  #
  def - arg
    case arg
    when Numeric
      Matrix.Raise ErrOperationNotDefined, "-", self.class, arg.class
    when Vector
      arg = Matrix.column_vector( arg )
    when Matrix
    else
      compat_1, compat_2 = arg.coerce self
      return compat_1 - compat_2
    end

    Matrix.Raise ErrDimensionMismatch unless
      row_size == arg.row_size and column_size == arg.column_size

    rows = Array.new( row_size ) { |i|
      Array.new( column_size ) { |j|
        self[i, j] - arg[ i, j ]
      }
    }
    new_matrix rows, column_size
  end

  # aliasing #row_size, #column_size
  alias :number_of_rows :row_size
  alias :number_of_columns :column_size
  alias :height :number_of_rows
  alias :width :number_of_columns
end

class Vector
  # .zero class method returns a vector filled with zeros
  # 
  def zero( vector_size )
    self[*([TOTAL_ZERO.new] * vector_size)]
  end
end
