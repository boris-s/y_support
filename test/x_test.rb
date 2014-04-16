#! /usr/local/bin/ruby
# encoding: utf-8

require 'minitest/autorun'

describe "y_support/x" do
  before do
    require './../lib/y_support/x'
    YSupport::X.echo_primary_clipboard '"foo & bar"'
    YSupport::X.echo_secondary_clipboard "baz"
  end

  it "should have clipboard as expected" do
    assert_equal '"foo & bar" baz', [`xsel -b`, `xsel -s`].join(' ')
  end

  it "should know #query_box and #message_box methods" do
    assert_respond_to YSupport::X, :query_box
    assert_respond_to YSupport::X, :message_box
  end
end # describe "y_support/x"
