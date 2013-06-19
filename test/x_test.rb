#! /usr/local/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require './../lib/y_support/x'

class XTest < Test::Unit::TestCase
  context "X" do
    setup do
      YSupport::X.echo_primary_clipboard "hello"
      YSupport::X.echo_secondary_clipboard "world"
    end

    should "have clipboard as expected" do
      assert_equal "hello world", [`xsel -b`, `xsel -s`].join(' ')
    end
  end # context X
end # class XTest
