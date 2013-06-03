# -*- coding: utf-8 -*-
require 'y_support'
require 'active_support/core_ext/array/extract_options'

# FIXME: Now, here, in order for the token game to work properly with
# guarding system, several things have to be done. Firstly,
# Place#set_marking( marking, blame ) will have to be implemented,
# and in Place#add, blame argument will have to be added
# Now with that blame, the transition will have to explain what it is
# trying to do. So actually it should be a block
#
# It's gonna be a mixin, Conscience, or something like that, and it will
# imbue the receiving class with the ability to try something.
#
# Transition.try "to fire!" do
#   if assignment_action? then
#     note has: "assignment action"
#     note "Δt", is: Δt
#     note "domain marking" is: domain_marking
#     act = note "Action" do Array action( Δt ) end
#     codomain.each_with_index do |place, i|
#       try "set the marking of place #{place} to the #{i}-th element of the action vector (#{act[i]})" do
#         place.marking = act[i]
#       end
#     end
#   else
#     etc. etc. etc.
# end
#
# Should produce error messages like this:
# When trying to fire! the transition #{self}, having assignment action, with Δt being #{Δt}, action has
# been computed to #{Array action(Δt)}, when trying to set the marking of plac #{place} to the #{i}-th
# element of the action vector (#{act[i]}), GuardError was encountered, with the message: ..."
#
# Yes, this is a managed code miniframework that I need here.
#
module Conscience
  class Try
    PUSH_ORDERED = -> ary, e {
      named = ary.extract_options!
      ary << e << named
    }
    PUSH_NAMED = -> ary, k, v {
      named = ary.extract_options!
      ary << named.update( k => v )
    }
    DECORATE = -> str, prefix: '', postfix: '' {
      str.to_s.tap { |ς| return ς.empty? ? '' : prefix + ς + postfix }
    }
    TRANSITIVE = Hash.new do |ꜧ, key| "#{key}ing %s" end
      .update( is: "being %s",
               has: "having %s" )
    STATE = Hash.new do |ꜧ, key| "#{key} %s" end
      .update( is: "%s",
               has: "has %s" )

    attr_reader :_object_, :_text_, :_block_, :_facts_

    def initialize( object: nil, text: nil, &block )
      @_object_, @_text_, @_block_ = object, text, block
      @_facts_ = Hash.new do |ꜧ, key| ꜧ[key] = [ {} ] end
    end

    def note *subjects, **statements, &block
      return *Array( subjects ).each do |s|
        PUSH_ORDERED.( _facts_[s], s )
      end if statements.empty?
      subjects << _object_ if subjects.empty?
      Array( subjects ).each do |subj|
        statements.each do |verb, object|
          PUSH_NAMED.( _facts_[subj], verb, object )
        end
      end
      return statements.first[1]
    end

    def call *args
      begin
        instance_exec *args, &_block_
      rescue StandardError => err
        txt1 = "When trying #{_text_}"
        thing, statements = _describe_
        txt2 = DECORATE.( thing, prefix: ' ' )
        txt3 = DECORATE.( statements.map { |verb, object|
                            STATE[verb] % object
                          }.join( ', ' ),
                          prefix: ' (', postfix: ')' )
        txt4 = DECORATE.( _circumstances_, prefix: ', ' )
        txt5 = DECORATE.( "#{err.class} occurred: #{err}", prefix: ', ' )
        raise err, txt1 + txt2 + txt3 + txt4 + txt5
      end
    end

    def method_missing sym, *args
      _object_.send sym, *args
    end

    private

    def _describe_ obj=_object_
      facts = _facts_[obj].dup
      statements = facts.extract_options!
      fs = facts.join ', '
      if statements.empty? then
        return fs, statements
      else
        return facts.empty? ? obj.to_s : fs, statements
      end
    end

    def _circumstances_
      _facts_.reject { |subj, _| subj == _object_ }.map { |subj, _|
        thing, statements = _describe_( subj )
        thing + DECORATE.( statements.map { |v, o|
                             TRANSITIVE[v] % o
                           }.join( ', ' ),
                           prefix: ' ' )
      }.join( ', ' )
    end
  end

  # Try method taxes two textual arguments and one block. The first (optional)
  # textual argument describes what is the receiver of #try. The second argument
  # describes in plain speech what activity is #try attempting. The block that
  # follows then contains the code, which performs that activity. In the block,
  # #note method is available, that builds up the context for the error message,
  # if any.
  # 
  def try object=self, to_do_something, &block
    Try.new( object: object, text: to_do_something, &block ).call
  end
end
