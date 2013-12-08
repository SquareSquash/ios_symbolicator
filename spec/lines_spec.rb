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

describe Squash::Symbolicator::Lines do
  describe "#add" do
    before(:each) { @lines = Squash::Symbolicator::Lines.new }

    it "should add a line descriptor in the proper location" do
      @lines.add 30, 'file1', 1, 2
      @lines.add 10, 'file2', 2, 3
      @lines.add 1, 'file3', 3, 4
      @lines.add 20, 'file4', 4, 5

      expect(@lines.size).to eql(4)

      expect(@lines[0].start_address).to eql(1)
      expect(@lines[0].file).to eql('file3')
      expect(@lines[0].line).to eql(3)
      expect(@lines[0].column).to eql(4)

      expect(@lines[1].start_address).to eql(10)
      expect(@lines[1].file).to eql('file2')
      expect(@lines[1].line).to eql(2)
      expect(@lines[1].column).to eql(3)

      expect(@lines[2].start_address).to eql(20)
      expect(@lines[2].file).to eql('file4')
      expect(@lines[2].line).to eql(4)
      expect(@lines[2].column).to eql(5)

      expect(@lines[3].start_address).to eql(30)
      expect(@lines[3].file).to eql('file1')
      expect(@lines[3].line).to eql(1)
      expect(@lines[3].column).to eql(2)
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
      expect(@lines.for(4).start_address).to eql(1)
      expect(@lines.for(4).file).to eql('file2')
      expect(@lines.for(4).line).to eql(2)
      expect(@lines.for(4).column).to eql(3)
    end

    it "should return nil for unknown addresses" do
      expect(@lines.for(2356)).to be_nil
    end

    it "should return the last line for the highest address" do
      expect(@lines.for(715).file).to eql('file4')
    end

    it "should return nil for an empty object" do
      expect(Squash::Symbolicator::Lines.new.for(15)).to be_nil
    end
  end
end
