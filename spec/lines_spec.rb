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

describe Squash::Symbolicator::Lines do
  describe "#add" do
    before(:each) { @lines = Squash::Symbolicator::Lines.new }

    it "should add a line descriptor in the proper location" do
      @lines.add 30, 'file1', 1, 2
      @lines.add 10, 'file2', 2, 3
      @lines.add 1, 'file3', 3, 4
      @lines.add 20, 'file4', 4, 5

      @lines.size.should eql(4)

      @lines[0].start_address.should eql(1)
      @lines[0].file.should eql('file3')
      @lines[0].line.should eql(3)
      @lines[0].column.should eql(4)

      @lines[1].start_address.should eql(10)
      @lines[1].file.should eql('file2')
      @lines[1].line.should eql(2)
      @lines[1].column.should eql(3)

      @lines[2].start_address.should eql(20)
      @lines[2].file.should eql('file4')
      @lines[2].line.should eql(4)
      @lines[2].column.should eql(5)

      @lines[3].start_address.should eql(30)
      @lines[3].file.should eql('file1')
      @lines[3].line.should eql(1)
      @lines[3].column.should eql(2)
    end
  end

  describe "#for" do
    before :all do
      @lines = Squash::Symbolicator::Lines.new
      @lines.add 10, 'file1', 1, 2
      @lines.add 1, 'file2', 2, 3
      @lines.add 15, 'file3', 3, 4
      @lines.add 715, 'file4', 4, 5
    end

    it "should return the line with the smallest matching range" do
      @lines.for(4).start_address.should eql(1)
      @lines.for(4).file.should eql('file2')
      @lines.for(4).line.should eql(2)
      @lines.for(4).column.should eql(3)
    end

    it "should return nil for unknown addresses" do
      @lines.for(2356).should be_nil
    end

    it "should return the last line for the highest address" do
      @lines.for(715).file.should eql('file4')
    end

    it "should return nil for an empty object" do
      Squash::Symbolicator::Lines.new.for(15).should be_nil
    end
  end
end
