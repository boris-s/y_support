#! /usr/bin/ruby

require 'minitest/spec'
require 'minitest/autorun'
# require 'y_support/try'     # tested component itself
require './../lib/y_support/try'

describe Consciously do
  before do
    @try = Consciously::Try.new object: "Dummy", text: "to fire" do
      note is: "dummy"
      note has: "no care in the world"
      n = note "its number", is: 42
      raise TypeError, 'foo'
    end
  end

  it "should have basic functionality" do
    assert_equal "to fire", @try.__txt__
    assert_equal "Dummy", @try.__obj__
    assert_equal 0, @try.__facts__.size # haven't tried anything yet
    @try.__facts__["something"]
    assert_equal 1, @try.__facts__.size
    @try.note is: 'dummy'
    @try.note has: 'no care in the world'
    assert_equal 2, @try.__facts__.size
    assert_equal ["something", "Dummy"], @try.__facts__.keys
    assert_equal( [ { is: "dummy", has: "no care in the world" } ],
                  @try.__facts__["Dummy"] )
    assert_equal " hello!", Consciously::Try::DECORATE.( :hello, prefix: ' ', postfix: '!' )
    assert_equal( ['Dummy', {is: 'dummy', has: 'no care in the world'}],
                  @try.__describe__( "Dummy" ) )
  end

  describe 'case 1' do
    it "should work" do
      begin
        @try.__invoke__
      rescue TypeError => err
        expected_msg = "When trying to fire Dummy (dummy, has no care in " +
          "the world), its number being 42, TypeError occurred: foo"
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
      -> { o.try "to call a missing method" do hello! end }.must_raise NoMethodError
    end
  end

  describe 'case 4' do
    it "should work" do
      begin
        "FooBar".try "to do something" do
          note has: "#{size} letters", is: "a #{self.class} instance"
          unless include? "Quux"
            note "Quux", is: "not a part of it"
            try "to append Quux to it" do
              self << "Quux"
              fail "EPIC FAIL"
            end
          end
        end
      rescue => err
        err.message.must_equal 'When trying to do something, FooBar having ' +
          '6 letters, being a String instance, Quux being not a part of it, ' +
          'RuntimeError occurred: When trying to append Quux to it, ' +
          'RuntimeError occurred: EPIC FAIL'
      end
    end
  end
end
