# encoding: utf-8

require_relative '../y_support'
require_relative '../y_support/core_ext/array/misc'

# Provides +Try+ class, and +Object#try+ method that constructs and calls a
# +Consciously::Try+ instance. This +#try+ method has nothing to do with the
# error-swallowing +#try+ method frequently seen elsewhere. On the contrary,
# our +#try+ method _facilitates_ raising and ultimately, correcting errors
# by providing well-formed error messages.
#
# Constructing error messages is labor-intensive. +Consciously::Try+ allows one
# to construct verbose error messages with +#note+ statements inside the block,
# that act as comments at the same time.
#
#   "FooBar".try "to do something" do
#     note has: "#{size} letters", is: "a #{self.class} instance"
#     unless include? "Quux"
#       note "Quux", is: "not a part of it"
#       try "to append Quux to it" do
#         self << "Quux"
#         fail "EPIC FAIL"
#       end
#     end
#   end
#
# Should produce an automatic error message like this: "When trying to do
# something, FooBar having 6 letters, being a String instance, Quux being
# not a part of it, RuntimeError occurred: When trying to append Quux to it,
# RuntimeError occurred: EPIC FAIL"
#
module Consciously
  class Try < BasicObject
    DECORATE = -> str, prefix: '', postfix: '' {
      str.to_s.tap { |ς| return ς.empty? ? '' : prefix + ς + postfix }
    }
    TRANSITIVE = ::Hash.new do |ꜧ, key| "#{key}ing %s" end
      .update( is: "being %s",
               has: "having %s" )
    STATE = ::Hash.new do |ꜧ, key| "#{key} %s" end
      .update( is: "%s",
               has: "has %s" )

    attr_reader :__obj__, :__txt__, :__bl__, :__facts__

    # This 
    def initialize( object: nil, text: nil, &block )
      @__obj__, @__txt__, @__bl__ = object, text, block
      @__facts__ = ::Hash.new do |hsh, key| hsh[key] = [ {} ] end
    end

    # The syntax of this method, available inside the #try block, is:
    # 
    #   note "Concatenation of Foo and Bar", is: "FooBar", has: "6 letters"
    #
    def note *subjects, **statements, &block
      return Array( subjects ).each { |s| __facts__[s].push_ordered s } if
        statements.empty?
      subjects << __obj__ if subjects.empty?
      Array( subjects ).each { |subj|
        statements.each { |verb, obj| __facts__[subj].push_named verb => obj }
      }
      return statements.first[1]
    end

    # Invokes the Try object's block.
    # 
    def __invoke__ *args
      begin
        instance_exec *args, &__bl__
      rescue ::StandardError => err
        txt1 = "When trying #{__txt__}"
        thing, statements = __describe__
        txt2 = DECORATE.( thing, prefix: ' ' )
        txt3 = DECORATE.( statements.map { |verb, object|
                            STATE[verb] % object
                          }.join( ', ' ),
                          prefix: ' (', postfix: ')' )
        txt4 = DECORATE.( __circumstances__, prefix: ', ' )
        txt5 = DECORATE.( "#{err.class} occurred: #{err}", prefix: ', ' )
        raise err, txt1 + txt2 + txt3 + txt4 + txt5
      end
    end

    def try *args, &block
      __obj__.try *args, &block
    end

    def method_missing sym, *args
      __obj__.send sym, *args
    end

    def __describe__ obj=__obj__
      facts = __facts__[obj].dup
      statements = if facts.last.is_a? ::Hash then facts.pop else {} end
      fs = facts.join ', '
      if statements.empty? then
        return fs, statements
      else
        return facts.empty? ? obj.to_s : fs, statements
      end
    end

    def __circumstances__
      __facts__.reject { |subj, _| subj == __obj__ }.map { |subj, _|
        thing, statements = __describe__( subj )
        thing + DECORATE.( statements.map { |v, o|
                             TRANSITIVE[v] % o
                           }.join( ', ' ),
                           prefix: ' ' )
      }.join( ', ' )
    end
  end
end


class Object
  # Try method takes two textual arguments and one block. The first (optional)
  # argument is a natural language description of the method's receiver (with
  # #to_s of the receiver used by default). The second argument is a natural
  # language description of the supplied block's _contract_ -- in other words,
  # what the supplied block tries to do. Finally, the block contains the code
  # to perform the described risky action. Inside the block, +#note+ method is
  # available, which builds up the context information for a good error message,
  # should the risky action raise one.
  # 
  def try receiver_NL_description=self, attempt_NL_description, &block
    Consciously::Try.new( object: receiver_NL_description,
                         text: attempt_NL_description,
                         &block ).__invoke__
  end
  alias consciously try
end
