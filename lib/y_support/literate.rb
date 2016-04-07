# encoding: utf-8

require_relative '../y_support'
require_relative '../y_support/core_ext/array/misc'

# Did you ever get in the situation that your code does not work
# and you don't know what the problem is? In Ruby, error messages
# are supposed to help you, but how often have you seen error
# messages telling you completely unhelpful things, such as that
# some method is not defined for nil:NilClass? Anyone who
# programmed in Ruby for some time knows that raising good error
# messages is a pain and the code that raises them tends to make
# all your methods look ugly. YSupport's answer to this is Literate
# (loaded by require 'y_support/literate'). Literate offers +#try+
# block, inside which you can construct verbose error messages with
# k +#note+ statements. Note that this +#try+ method has nothing to
# do with the infamous error-swallowing +#try+ method seen and
# denounced elsewhere. Literate's +#try+ method does not swallow
# errors – on the contrary, it helps to raise them. Comments you
# make via +#note+ method (or its alias #») inside +#try+ blocks
# will be used to construct more informative error messages. Good
# error messages ultimately lead to better code and more scalable
# development. Simple example:
#
#   "lorem ipsum dolor sit amet".try "to split it into words" do
#     note is: "a natural language sentence"
#     note has: "#{size} characters"
#     words = split ' '
#   end
#
# This is not really such a good example, because #try method is
# intended for risky operation, and splitting a string into words
# is not risky at all. But it clearly shows how Literate works.
# Since the era of programs written on punch cards, programmers
# already understood that writing code comments is a good
# practice. The keystrokes you waste by literate coding will pay
# off as soon as you start doing any serious programming. With
# Literate, you can take literate coding to the next level by
# writing self-documenting code, in which comments introduced by
# #note method are read by the interpeter and used to construct
# error messages. All you need to learn is how to use +#try+ and
# +#note+ methods.
#
# Literate relies on +Literate::Attempt+ class, which stays hidden
# behind the scene, but defines all the error-raising capabilities
# of +#try+ blocks.
#
module Literate
  # Represents a commented attempt to perform a risky operation,
  # which may result in errors. The operation code is supplied as
  # a block. Method #comment defined by this class helps to
  # increase the informative value of error messages.
  # 
  class Attempt < BasicObject
    # String construction closures are defined below.
    DECORATE = -> string, prefix: '', postfix: '' do
      s = string.to_s
      if s.empty? then '' else prefix + s + postfix end
    end

    # Hash of transitive verb forms.
    TRANSITIVE = ::Hash.new do |_, key| "#{key}ing %s" end
      .update( is: "being %s", has: "having %s" )

    # Hash for construction of statements (error message parts).
    STATE = ::Hash.new do |ꜧ, key| "#{key} %s" end
      .update( is: "%s", has: "has %s" )

    # An Attempt instance has 4 properties.
    attr_reader :__subject__ # Grammatical subject of the attempt.
    attr_reader :__block__   # Block that performs the attempt.
    attr_reader :__text__    # NL description of the attempt.
    attr_reader :__knowledge_base__

    # Attempt constructor expects two parameters (:subject and
    # :text) and one block. Argument of the :subject parameter is
    # the main subject of the risky operation attempted inside the
    # block. Argument of the :text parameter is the natural
    # language textual description of the risky opration.
    # 
    def initialize( subject: nil, text: nil, &block )
      @__subject__ = subject
      @__text__ = text
      @__block__ = block
      # Knowledge base is a list of subjects and facts known
      # about them.
      @__knowledge_base__ = ::Hash.new do |hash, missing_key|
        hash[ missing_key ] = [ {} ]
      end
    end

    # Method #note is available inside the #try block
    # 
    #   note "Concatenation of Foo and Bar",
    #        is: "FooBar",
    #        has: "6 letters"
    #
    def note *subjects, **statements, &block
      if statements.empty? then
        # No statements were supplied to #note.
        subjects.each { |subject|
          # Fill in the knowledge base ...
          # FIXME: I wonder how the code here works.
          __knowledge_base__[ subject ].push_ordered subject
        }
        # FIXME: I wonder whether returning this is OK.
        return subjects
      end
      # Here, we know that variable statements is not empty.
      # If subjects variable is empty, assume main subject.
      subjects << __subject__ if subjects.empty?
      # Fill the knowledge base ...
      # FIXME: I wonder how the code here works.
      subjects.each { |subject|
        statements.each do |verb, object|
          __knowledge_base__[ subject ].push_named verb => object
        end
      }
      # Return the second element of the first statement.
      return statements.first[ 1 ]
    end

    # Alias of #note method that allows comments such as this:
    #
    # a = []
    # a.try "to insert number one in it" do
    #   » is: "an empty array"
    #   push 1
    # end
    # 
    alias » note

    # Runs the attempt.
    # 
    def __run__ *args
      begin
        instance_exec *args, &__block__
      rescue ::StandardError => error
        # Error has occured. Show time for Literate::Attempt.
        raise error, __error_message__( error )
      end
    end

    # Facilitating error messages is the main purpose of Literate.
    # This method is invoked when an error occurs inside the block
    # run by Literate::Attempt instance and it constructs a verbose
    # error message using the facts the Attempt instance knows.
    # 
    def __error_message__ error
      # Write the first part of the error message.
      part1 = "When trying #{__text__}"
      # Get the description of the main subject.
      subject, statements = __describe__( __subject__ )
      # Write the 2nd part of the error message.
      part2 = DECORATE.( subject, prefix: ' ' )
      # Construct the descriptive string of the main subject.
      subject_description = statements.map { |verb, object|
        # Generate the statement string.
        STATE[ verb ] % object
      }.join ', ' # join the statement strings with commas
      # Write the third part of the error message.
      part3 = DECORATE.( subject_description,
                         prefix: ' (', postfix: ')' )
      # Write the fourth part of the error message.
      part4 = DECORATE.( __circumstances__, prefix: ', ' )
      # Write the fifth part of the error message.
      part5 = DECORATE.( "#{error.class} occurred: #{error}", 
                          prefix: ', ' )
      return part1 + part2 + part3 + part4 + part5
    end

    # Inside the block, +#try method is delegated to the subject
    # of the attempt.
    # 
    def try *args, &block
      __subject__.try *args, &block
    end

    # Method missing delegates all methods not recognized by
    # Literate::Attempt class (which is a subclass of BasicObject)
    # to the subject of the attempt.
    # 
    def method_missing symbol, *args
      __subject__.send symbol, *args
    end

    # Produces a description of the subject supplied to the method.
    # 
    def __describe__ subject
      # Start with the facts known about the subject.
      facts = __knowledge_base__[ subject ].dup
      # FIXME: I wonder what this method is *really* doing.
      # It seems that I wrote this library too quickly and didn't
      # bother with properly defining its list of facts.
      # I did not define what is a "fact", what is a "statement"
      # etc., I just go around using the words and hoping I will
      # understand it after myself later. I found it's quite hard.
      statements = if facts.last.is_a? ::Hash then
                     facts.pop
                   else {} end
      fs = facts.join ', '
      if statements.empty? then
        return fs, statements
      else
        return facts.empty? ? subject.to_s : fs, statements
      end
    end

    # Produces description of the circumstances, that is,
    # concatenated descriptions of all facts known to the Attempt
    # instance except those about the main subject of the attempt.
    # 
    def __circumstances__
      # Start with all facts known to the Attempt instance.
      base = __knowledge_base__
      # Ignore the facts about the main subject.
      circumstances = base.reject { |s, _| s == __subject__ } 
      # Construct descriptive strings of the remaining facts.
      fact_strings = circumstances.map { |subject, _|
        subject, statements = __describe__( subject )
        statements = statements.map { |verb, object|
          TRANSITIVE[ verb ] % object
        }.join( ', ' )
        # Create the fact string.
        subject + DECORATE.( statements, prefix: ' ' )
      }
      # Concatenate the fact strings and return the result.
      return fact_strings.join( ', ' )
    end
  end
end

class Object
  # Try method takes two textual arguments and one block. The first
  # (optional) argument is a natural language description of the
  # method's receiver (with #to_s of the receiver used by
  # default). The second argument is a natural language description
  # of the supplied block's _contract_ -- in other words, what the
  # supplied block tries to do. Finally, the block contains the
  # code to perform the described risky action. Inside the block,
  # +#note+ method is available, which builds up the context
  # information for a good error message, should the risky action
  # raise one.
  # 
  def try attempt_description, &block
    # Construct a new Attempt instance.
    attempt = Literate::Attempt.new subject: self,
                                    text: attempt_description,
                                    &block
    # Run the block.
    attempt.__run__
  end
end
