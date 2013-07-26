# Copyright 2013 Square Inc.
#
#    Licensed under the Apache License, Version 2.0 (the "License");
#    you may not use this file except in compliance with the License.
#    You may obtain a copy of the License at
#
#        http://www.apache.org/licenses/LICENSE-2.0
#
#    Unless required by applicable law or agreed to in writing, software
#    distributed under the License is distributed on an "AS IS" BASIS,
#    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#    See the License for the specific language governing permissions and
#    limitations under the License.

require 'serialbox'

Squash::Symbolicator::Line = Struct.new(:start_address, :file, :line, :column)

# An address ranged mapped to a specific line of code, as part of a {Lines}
# aggregation. No symbol data is included.

class Squash::Symbolicator::Line
  include SerialBox
  serialize_with :JSON
  serialize_fields do |s|
    s.serialize :start_address, :file, :line, :column
  end

  # @private
  def <=>(other)
    raise ArgumentError unless other.kind_of?(Squash::Symbolicator::Line)
    start_address <=> other.start_address
  end
end

# An aggregation of the `Symbolicator::Line`s of a binary class. This class
# is enumerable.

class Squash::Symbolicator::Lines
  include Enumerable

  include SerialBox
  serialize_with :JSON
  serialize_fields { |s| s.serialize :@lines }

  # Creates a new empty aggregation.

  def initialize
    @lines = Array.new
  end

  # Adds a line definition to the aggregation.
  #
  # @param [Fixnum] start_address The lowest program counter address
  #   corresponding to this method or function.
  # @param [String] file The path to the file where this line is found.
  # @param [Fixnum] lineno The line number in `file`.
  # @param [Fixnum] col The column number in `file`.

  def add(start_address, file, lineno, col)
    index   = @lines.find_index { |line| line.start_address > start_address }
    new_line = Squash::Symbolicator::Line.new(start_address, file, lineno, col)

    if index
      @lines.insert index, new_line
    else
      @lines << new_line
    end
  end

  # Returns the nearest `Symbolicator::Line` to a given program counter address.
  #
  # @param [Fixnum] address A program counter address.
  # @return [Symbol, nil] The line corresponding to that address, or `nil` if
  #   the address is not symbolicated.

  def for(address)
    return @lines.last if @lines.last && @lines.last.start_address == address
    idx = @lines.find_index { |line| address < line.start_address }
    return nil unless idx
    return @lines[idx - 1]
  end

  # Delegated to `Array`.
  def each(*args) @lines.each(*args) end
  # Delegated to `Array`.
  def [](*args) @lines[*args] end
  # Delegated to `Array`.
  def clear(*args) @lines.clear(*args) end
  # Delegated to `Array`.
  def size(*args) @lines.size(*args) end

  # @private
  def inspect() "#<#{self.class} [#{size} lines]>" end
end
