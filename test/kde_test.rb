#! /usr/bin/ruby
#encoding: utf-8

require 'test/unit'
require 'shoulda'

class KDETest < Test::Unit::TestCase
  context "KDE" do
    setup do
      require 'y_support/kde'
    end

    should "have module method #show_file_with_kioclient" do
      assert_respond_to YSupport::KDE, :show_file_with_kioclient
    end
  end # context KDE
end # class KDETest
