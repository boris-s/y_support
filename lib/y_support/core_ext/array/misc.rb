class Array
  # Converts an array, whose elements are also arrays, to a hash. Head
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


  # Zips this array with another collection into a hash. If a block is given,
  # it is applied
  # and an optional block, and returns a hash whose keys are the collection
  # members, and whose values are given by the supplied othe arguments and/or
  # block in the following way: If there is no additional argument, but a block
  # is supplied, this is applied to the collection. If there is exactly one
  # other argument, and it is also a collection, it is used as values.
  # Otherwise, these other arguments are treated as a message to be sent to
  # self (via #send), expecting it to return a collection to be used as hash
  # values. Optional block (which is always assumed to be unary) can be used
  # to additionally modify the second collection.
  # 
  def zip_to_hash collection=nil
    if block_given? then
      fail ArgumentError, "Argument not allowed if block given!" unless
        collection.nil?
      Hash[ zip( collection.map { |e| yield e } ) ]
    else
      fail ArgumentError "A second collection expected as an argument!" unless
        collection.respond_to? :each
      Hash[ zip( collection ) ]
    end
  end


  def >> collection

  # Allows style &[ function, *arguments ]
  # 
  def to_proc
    proc { |receiver| receiver.send *self }
  end # def to_proc

  # With array construction syntax [:foo, bar: 42] now possible in Ruby, arrays
  # become closer to argument collections, and supporting methods might come
  # handy. This method pushes an element on top of the "ordered arguments" part
  # of the array.
  # 
  def push_ordered element
    return push element unless last.is_a? Hash
    push pop.tap { push element }
  end

  # With array construction syntax [:foo, bar: 42] now possible in Ruby, arrays
  # become closer to argument collections, and supporting methods might come
  # handy. This method pushes an element on top of the "named arguments" part
  # of the array.
  # 
  def push_named **oo
    l = last
    return push oo unless l.is_a? Hash
    tap { l.update oo }
  end

  # With array construction syntax [:foo, bar: 42] now possible in Ruby, arrays
  # become closer to argument collections, and supporting methods might come
  # handy. This method pops an element from the "ordered arguments" array part.
  # 
  def pop_ordered
    l = pop
    return l unless l.is_a? Hash
    pop.tap { push l }
  end

  # With array construction syntax [:foo, bar: 42] now possible in Ruby, arrays
  # become closer to argument collections, and supporting methods might come
  # handy. This method pops an element from the "ordered arguments" array part.
  # 
  def pop_named key
    l = last
    l.delete( key ).tap { pop if l.empty? } if l.is_a? Hash
  end
  
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
