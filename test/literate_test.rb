#! /usr/bin/ruby
# coding: utf-8

require 'minitest/autorun'
# require 'y_support/literate'     # tested component itself
require './../lib/y_support/literate'

describe Literate::Attempt do
  before do
    @str = "lorem ipsum dolor sit amet"
    @txt = "split the sentence into words"
    # A simple attempt block.
    @a = Literate::Attempt.new subject: @str, text: @txt do
      note is: "natural language sentence"
      split ' '
    end
    # More verbose attempt block.
    chosen_word = 3
    @b = Literate::Attempt.new subject: @str, text: @txt do
      » is: "natural language sentence"
      » has: "#{size} characters"
      words = split ' '
      » "number of words", is: words.size
      » "chosen word", is: words[ chosen_word ]
      words
    end
  end

  it "should have 4 basic properties" do
    @a.__text__.must_equal @txt
    @a.__subject__.must_equal @str
    @a.__block__.must_be_kind_of Proc
    @a.__knowledge_base__.must_be_empty
    # Fact list is empty because the block hasn't been run yet.
    # Let's run the block:
    @a.__run__
    # Now the fact list includes the comment made in the block.
    @a.__knowledge_base__.size.must_equal 1
  end

  describe "#__run__" do
    it "must run the attempt's block" do
      expected_result = "lorem", "ipsum", "dolor", "sit", "amet"
      @a.__run__.must_equal expected_result
    end
  end

  describe "Object#try method" do
    before do
      error = false
      @error_switch = -> arg { error = arg }
      @text = "to split into words"
      @block = proc do
        note is: "a string with several words"
        fail error if error
        split ' '
      end
    end

    it "must execute the block allowing subject's methods" do
      "hello world".try( @text, &@block )
        .must_equal [ "hello", "world" ]
      @error_switch.( TypeError )
      -> { "hello world".try @text, &@block }.must_raise TypeError
      @error_switch.( NameError )
      -> { "hello world".try @text, &@block }.must_raise NameError
    end

    it "must allow Literate::Attempt#comment inside the block" do
      begin
        @error_switch.( TypeError )
        "hello world".try @text, &@block
      rescue => error
        # Proof that Literate::Attemp#comment activated.
        m = error.message
        m.must_include "When trying to split into words"
        m.must_include "a string with several words"
      else
        flunk "Error expected but nothing raised!"
      end
    end
  end

  describe "#note" do
    it "must write entries into @__knowledge_base__" do
      @a.__run__
      x = { @str => [ is: "natural language sentence" ] }
      @a.__knowledge_base__.must_equal x
    end

    it "must write entries into @__knowledge_base__" do
      @b.__run__
      x = { @str => [ is: "natural language sentence",
                      has: "26 characters" ],
            "number of words" => [ is: 5 ],
            "chosen word" => [ is: "sit" ] }
      @b.__knowledge_base__ .must_equal x
    end
  end

  describe "#__describe__" do
    it "must produce description of the main subject" do
      @a.__run__
      @a.__describe__( @a.__subject__ )
        .must_equal [ "lorem ipsum dolor sit amet",
                      { is: "natural language sentence" } ]
      @b.__run__
      @b.__describe__( @a.__subject__ )
        .must_equal [ "lorem ipsum dolor sit amet",
                      { is: "natural language sentence",
                        has: "26 characters" } ]
    end
  end

  describe "#__circumstances__" do
    it "..." do
      @a.__run__
      @a.__circumstances__.must_equal ""
      @b.__run__
      @b.__circumstances__
        .must_equal "number of words being 5, " +
                    "chosen word being sit"
    end
  end
end

describe "usecase 1: name validator" do
  before do
    @name_validator = Object.new
    @name_validator.define_singleton_method :validate do |name|
      name.to_s.try "to validate the requested name" do
        note "rejecting non-capitalized names"
        fail NameError unless ( ?A..?Z ) === self[0]
        note "rejecting names with spaces"
        fail NameError unless split( ' ' ).size == 1
      end
      return name
    end
  end

  it "should validate good names" do
    @name_validator.validate( :Fred ).must_equal :Fred
    @name_validator.validate( "Su_san" ).must_equal "Su_san"
  end

  it "should reject bad names with a good error message" do
    expected_message =
      "When trying to validate the requested name, rejecting " +
      "non-capitalized names: NameError!"
    begin
      @name_validator.validate( :fred )
    rescue => error
      error.message.must_equal expected_message
    end
  end
end

# describe 'case 1' do
#   it "should work" do
#     # begin
#     #   @a.__run__
#     # rescue TypeError => err
#     #   expected_msg = "When trying concatenation of an array " +
#     #                  "with 2 elements, TypeError occurred: " +
#     #                  "Lorem ipsum dolor sit amet!"
#     #   # Make sure the last 45 characters is OK.
#     #   assert_equal expected_msg[-45..-1], err.message[-45..-1]
#     #   # # Make sure that whole message is as expected.
#     #   # assert_equal expected_msg, err.message
#     # else
#     #   flunk "Expected TypeError error not raised!"
#     # end
#   end
# end

# describe 'case 2' do
#   it "should work" do
#     begin
#       try "to call constant Nothing" do Nothing end
#     rescue NameError => err
#       expected_msg = 'When trying to call constant Nothing, ' +
#         'NameError occurred: uninitialized constant Nothing'
#       assert_equal( expected_msg, err.message )
#     else
#       flunk "Expected NameError error not raised!"
#     end
#   end
# end

# describe 'case 3' do
#   it "should work" do
#     o = Object.new
#     class << o
#       def to_s; "THIS OBJECT" end
#       def hello!; "hello hello" end
#     end
#     # Object's methods must be callable
#     o.try "to say hello" do hello! end.must_equal "hello hello"
#     begin
#       o.try "to call a weird method" do goodbye! end
#     rescue NoMethodError => err
#       err.message.must_include "When trying to call a weird " +
#         "method, NoMethodError occurred: undefined method"
#       err.message.must_include "goodbye!"
#     end
#   end
# end

# describe 'case 4' do
#   it "should work" do
#     begin
#       "FooBar".try "to do something" do
#         comment has: "#{size} letters",
#                 is: "a #{self.class} instance"
#         unless include? "Quux"
#           comment "Quux", is: "not a part of it"
#           try "to append Quux to it" do
#             self << "Quux"
#             fail "EPIC FAIL"
#           end
#         end
#       end
#     rescue => err
#       err.message.must_equal "When trying to do something, " +
#         "FooBar having 6 letters, being a String instance, " +
#         "Quux being not a part of it, RuntimeError occurred: " +
#         "When trying to append Quux to it, RuntimeError " +
#         "occurred: EPIC FAIL"
#     end
#   end
# end
