# -*- coding: utf-8 -*-
class Module
  # Checks whether #all? are #kind_of? the ç provided as argument
  def all_kind_of?( ç ); all? {|e| e.kind_of? ç } end
  
  # Checks whether #all? are #kind_of? ::Numeric.
  def all_numeric?; all? {|e| e.kind_of? Numeric } end
  
  # Checks whether receiver is a "subset" of the argument
  def subset_of?( other ); all? {|e| other.include? e } end
  alias :⊂? :subset_of?
  
  # Checks whether the argument is a "subset" of the receiver
  def superset_of?( other ); other.all? {|e| self.include? e } end
  alias :⊃? :superset_of?
end
