# Copyright 2012 Square Inc.
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

# An address ranged mapped to a symbol (method or function name), as part of a
# {Symbols} aggregation. The file and line where the symbol is declared is also
# included.

Squash::Symbolicator::Symbol = Struct.new(:start_address, :end_address, :file, :line, :method)

Squash::Symbolicator::Symbol.send(:define_method, :<=>) do |other|
  raise ArgumentError unless other.kind_of?(Squash::Symbolicator::Symbol)
  if start_address == other.start_address
    end_address <=> other.end_address
  else
    start_address <=> other.start_address
  end
end

# An aggregation of the `Symbolicator::Symbol`s of a binary. This class is
# enumerable.

class Squash::Symbolicator::Symbols
  include Enumerable

  # Creates a new empty aggregation.

  def initialize
    @symbols = Array.new
  end

  # Adds a symbol definition to the aggregation.
  #
  # @param [Fixnum] start_address The lowest program counter address
  #   corresponding to this method or function.
  # @param [Fixnum] end_address The highest program counter address
  #   corresponding to this method or function.
  # @param [String] file The path to the file where this symbol is declared.
  # @param [Fixnum] line The line number in `file` where this symbol is
  #   declared.
  # @param [String] symbol The method or function name.

  def add(start_address, end_address, file, line, symbol)
    index   = @symbols.find_index { |sym| sym.start_address > start_address || (sym.start_address == start_address && sym.end_address >= end_address) }
    new_sym = Squash::Symbolicator::Symbol.new(start_address, end_address, file, line, symbol)

    if index
      @symbols.insert index, new_sym
    else
      @symbols << new_sym
    end
  end

  # Returns the `Symbolicator::Symbol` containing a given program counter
  # address. If there are symbols with overlapping address ranges, the one with
  # the smallest range is returned.
  #
  # @param [Fixnum] address A program counter address.
  # @return [Symbol, nil] The symbol corresponding to that address, or `nil` if
  #   the address is not symbolicated.

  def for(address)
    @symbols.detect { |sym| sym.start_address <= address && sym.end_address >= address }
  end

  # Delegated to `Array`.
  def each(*args) @symbols.each(*args) end
  # Delegated to `Array`.
  def [](*args) @symbols[*args] end
  # Delegated to `Array`.
  def clear(*args) @symbols.clear(*args) end
  # Delegated to `Array`.
  def size(*args) @symbols.size(*args) end

  # @private
  def inspect() "#<#{self.class} [#{size} symbols]>" end
end
