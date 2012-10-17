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

require 'spec_helper'

describe Squash::Symbolicator::Symbols do
  describe "#add" do
    before(:each) { @symbols = Squash::Symbolicator::Symbols.new }

    it "should add a symbol descriptor in the proper location" do
      @symbols.add 10, 20, 'file1', 1, 'meth1'
      @symbols.add 1, 10, 'file2', 2, 'meth2'
      @symbols.add 1, 5, 'file3', 3, 'meth3'
      @symbols.add 7, 15, 'file4', 4, 'meth4'

      @symbols.size.should eql(4)

      @symbols[0].start_address.should eql(1)
      @symbols[0].end_address.should eql(5)
      @symbols[0].file.should eql('file3')
      @symbols[0].line.should eql(3)
      @symbols[0].method.should eql('meth3')

      @symbols[1].start_address.should eql(1)
      @symbols[1].end_address.should eql(10)
      @symbols[1].file.should eql('file2')
      @symbols[1].line.should eql(2)
      @symbols[1].method.should eql('meth2')

      @symbols[2].start_address.should eql(7)
      @symbols[2].end_address.should eql(15)
      @symbols[2].file.should eql('file4')
      @symbols[2].line.should eql(4)
      @symbols[2].method.should eql('meth4')

      @symbols[3].start_address.should eql(10)
      @symbols[3].end_address.should eql(20)
      @symbols[3].file.should eql('file1')
      @symbols[3].line.should eql(1)
      @symbols[3].method.should eql('meth1')
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
      @symbols.for(4).start_address.should eql(1)
      @symbols.for(4).end_address.should eql(5)
      @symbols.for(4).file.should eql('file3')
      @symbols.for(4).line.should eql(3)
      @symbols.for(4).method.should eql('meth3')
    end

    it "should return nil for unknown addresses" do
      @symbols.for(235).should be_nil
    end
  end
end
