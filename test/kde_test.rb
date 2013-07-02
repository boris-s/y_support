#! /usr/bin/ruby
#encoding: utf-8

require 'minitest/spec'
require 'minitest/autorun'
require './../lib/y_support/kde'

describe YSupport::KDE do
  it "should at least respond to certain messages" do
    assert_respond_to YSupport::KDE, :show_file_with_kioclient
    assert_respond_to YSupport::KDE, :query_box
    assert_respond_to YSupport::KDE, :message_box
  end
end
