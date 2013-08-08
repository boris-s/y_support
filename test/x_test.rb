#! /usr/local/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'
require './../lib/y_support/x'

class XTest < Test::Unit::TestCase
  context "X" do
    setup do
      YSupport::X.echo_primary_clipboard '"foo"'
      YSupport::X.echo_secondary_clipboard "bar"
    end

    should "have clipboard as expected" do
      assert_equal '"foo" bar', [`xsel -b`, `xsel -s`].join(' ')
    end

    should "know #query_box and #message_box methods" do
      assert_respond_to YSupport::X, :query_box
      assert_respond_to YSupport::X, :message_box
    end
  end # context X
end # class XTest
