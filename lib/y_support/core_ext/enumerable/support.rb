# -*- coding: utf-8 -*-
class Enumerable
  # Checks whether #all? collection elements are #kind_of? module
  # supplied as an argument
  # 
  def all_kind_of?( kind )
    all? {|e| e.kind_of? kind }
  end
  
  # Checks whether #all? collection elements are #kind_of? Numeric.
  # 
  def all_numeric?
    all? {|e| e.kind_of? Numeric }
  end
  
  # Checks whether the receiver collection is fully included in the
  # collection supplied as an argument.
  # 
  def subset_of?( other_collection )
    all? {|e| other_collection.include? e }
  end
  alias :⊂? :subset_of?
  
  # Checks whether the receiver collection contains every element of
  # the collection supplied as an argument.
  # 
  def superset_of?( other_collection )
    other.all? {|e| self.include? e }
  end
  alias :⊃? :superset_of?
end
