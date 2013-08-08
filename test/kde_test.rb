#! /usr/bin/ruby
#encoding: utf-8

require 'minitest/autorun'
require './../lib/y_support/kde'

describe YSupport::KDE do
  it "should at least respond to certain messages" do
    assert_respond_to YSupport::KDE, :show_file_with_kioclient
  end
end
