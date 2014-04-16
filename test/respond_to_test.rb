#! /usr/bin/ruby
#encoding: utf-8

require 'minitest/autorun'

describe "y_support/typing" do
  before do
    require './../lib/y_support/respond_to'
  end

  describe Object do
    it "should have RespondTo() constructor" do
      assert_equal RespondTo, RespondTo( :inspect ).class
    end
  end

  describe RespondTo do
    it "should work" do
      assert_respond_to( RespondTo.new(:hello), :=== )
      assert RespondTo.new(:each_char) === "arbitrary string"
      assert ! ( RespondTo.new(:each_char) === Object.new )
      assert ! ( RespondTo.new(:improbab_method_name) === Object.new )
      # Now testing the intended RespondTo usage in case statements.
      assert case ?x
             when RespondTo.new(:each_char) then 1
             else false end
      assert ! case ?x
               when RespondTo.new(:improbab_method_name) then 1
               else false end
    end
  end

  describe Symbol do
    it "should have Symbol#~@ for .respond_to? case statements" do
      assert_kind_of RespondTo, ~:hello
      assert RespondTo(:<<) === "testing"
      assert case ?x
             when ~:each_char then 1
             else false end
      assert ! case ?x
               when ~:improbab_method_name then 1
               else false end
    end
  end
end
