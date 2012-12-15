class Array
  # Converts an array, whose elements are also arrays, to a hash.  Head
  # (position 0) of each array is made to point at the rest of the array
  # (tail), normally starting immediately after the head (position 1). The
  # starting position of the tail can be controlled by an optional
  # argument. Tails of 2 and more elements are represented as arrays.
  # 
  def to_hash( tail_from = 1 )
    self.reject { | e | e[0].nil? }.reduce({}) { |a, e|
      tail = e[tail_from..-1]
      a.merge( { e[0] => tail.size >= 2 ? tail : tail[0] } )
    }
  end
  
  # Does things for each consecutive pair (expects a binary block).
  # 
  def each_consecutive_pair
    if block_given?
      return self if ( n = self.size - 1 ) <= 0
      n.times.with_index{|i| yield( self[i], self[i+1] ) }
      return self
    else
      return Enumerator.new do |yielder|
        n.times.with_index{|i| yielder << [ self[i], self[i+1] ] } unless
          ( n = self.size - 1 ) <= 0
      end
    end
  end
  
  # Allows style &[ function, *arguments ]
  # 
  def to_proc
    proc { |receiver| receiver.send *self }
  end # def to_proc
  
  # TEST ME
  # def pretty_inspect
  #   each_slice( 4 ) { |slice|
  #     slice.map { |e|
  #       str = e.to_s[0..25]
  #       str + ' ' * ( 30 - str.size )
  #     }.reduce( :+ ) + "\n"
  #   }.reduce( :+ )
  # end
end
