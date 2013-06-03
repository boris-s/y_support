#! /usr/bin/ruby

require 'minitest/spec'
require 'minitest/autorun'
# require 'y_support/conscience'     # tested component itself
require './../lib/y_support/conscience'

include Conscience

describe Try do
  before do
    @try = Try.new object: "Dummy", text: "to fire" do
      note is: "dummy"
      note has: "no care in the world"
      n = note "the number", is: 42
      raise TypeError, 'foo'
    end
  end

  it "should have basic functionality" do
    assert_equal "to fire", @try._text_
    assert_equal "Dummy", @try._object_
    assert_equal 0, @try._facts_.size # haven't tried anything yet
    @try._facts_["something"]
    assert_equal 1, @try._facts_.size
    @try.note is: 'dummy'
    @try.note has: 'no care in the world'
    assert_equal 2, @try._facts_.size
    assert_equal ["something", "Dummy"], @try._facts_.keys
    assert_equal( [ { is: "dummy", has: "no care in the world" } ],
                  @try._facts_["Dummy"] )
    assert_equal " hello!", Try::DECORATE.( :hello, prefix: ' ', postfix: '!' )
    assert_equal( ['Dummy', {is: 'dummy', has: 'no care in the world'}],
                  @try.send( :_describe_, "Dummy" ) )
  end

  describe 'case 1' do
    it "should work" do
      begin
        @try.call
      rescue TypeError => err
        expected_msg = "When trying to fire Dummy (dummy, has no care in " +
          "the world), the number being 42, TypeError occurred: foo"
        assert_equal expected_msg, err.message
      else
        flunk "Expected TypeError error not raised!"
      end
    end
  end

  describe 'case 2' do
    it "should work" do
      begin
        try "to call constant Nonexistant" do Nonexistant end
      rescue NameError => err
        expected_msg = 'When trying to call constant Nonexistant, ' +
          'NameError occurred: uninitialized constant Nonexistant'
        assert_equal( expected_msg, err.message )
      else
        flunk "Expected NameError error not raised!"
      end
    end
  end

  describe 'case 3' do
    it "should work" do
      o = Object.new
      class << o
        def to_s; "THIS OBJECT" end
        def hello!; "hello hello" end
      end
      o.try "to call a missing method" do hello! end
    end
  end
end
