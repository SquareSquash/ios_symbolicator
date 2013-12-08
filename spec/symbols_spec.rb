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

require 'spec_helper'

describe Squash::Symbolicator::Symbols do
  describe "#add" do
    before(:each) { @symbols = Squash::Symbolicator::Symbols.new }

    it "should add a symbol descriptor in the proper location" do
      @symbols.add 10, 20, 'file1', 1, 'meth1'
      @symbols.add 1, 10, 'file2', 2, 'meth2'
      @symbols.add 1, 5, 'file3', 3, 'meth3'
      @symbols.add 7, 15, 'file4', 4, 'meth4'

      expect(@symbols.size).to eql(4)

      expect(@symbols[0].start_address).to eql(1)
      expect(@symbols[0].end_address).to eql(5)
      expect(@symbols[0].file).to eql('file3')
      expect(@symbols[0].line).to eql(3)
      expect(@symbols[0].ios_method).to eql('meth3')

      expect(@symbols[1].start_address).to eql(1)
      expect(@symbols[1].end_address).to eql(10)
      expect(@symbols[1].file).to eql('file2')
      expect(@symbols[1].line).to eql(2)
      expect(@symbols[1].ios_method).to eql('meth2')

      expect(@symbols[2].start_address).to eql(7)
      expect(@symbols[2].end_address).to eql(15)
      expect(@symbols[2].file).to eql('file4')
      expect(@symbols[2].line).to eql(4)
      expect(@symbols[2].ios_method).to eql('meth4')

      expect(@symbols[3].start_address).to eql(10)
      expect(@symbols[3].end_address).to eql(20)
      expect(@symbols[3].file).to eql('file1')
      expect(@symbols[3].line).to eql(1)
      expect(@symbols[3].ios_method).to eql('meth1')
    end
  end

  describe "#for" do
    before :all do
      @symbols = Squash::Symbolicator::Symbols.new
      @symbols.add 10, 20, 'file1', 1, 'meth1'
      @symbols.add 1, 10, 'file2', 2, 'meth2'
      @symbols.add 1, 5, 'file3', 3, 'meth3'
      @symbols.add 7, 15, 'file4', 4, 'meth4'
    end

    it "should return the symbol with the smallest matching range" do
      expect(@symbols.for(4).start_address).to eql(1)
      expect(@symbols.for(4).end_address).to eql(5)
      expect(@symbols.for(4).file).to eql('file3')
      expect(@symbols.for(4).line).to eql(3)
      expect(@symbols.for(4).ios_method).to eql('meth3')
    end

    it "should return nil for unknown addresses" do
      expect(@symbols.for(235)).to be_nil
    end
  end
end
