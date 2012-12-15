#encoding: utf-8
require 'y_support'

# RespondTo class for easy use of respond_to? in case statements
class RespondTo
  Matchers = {}
  attr_reader :method
  def self.create method; Matchers[method] ||= new method end
  def initialize method; @method = method end
  def === obj; obj.respond_to? method end
end
