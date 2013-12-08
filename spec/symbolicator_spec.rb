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

describe Squash::Symbolicator do
  before :all do
    @symbolicator = Squash::Symbolicator.new('path', '/Users/tim/Development/SquashTester')
    @arch_output  = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'arch_output.txt'))
    @info_output  = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'info_output.txt'))
    @line_output  = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'line_output.txt'))
  end

  describe "#architectures" do
    it "should return a hash of architectures" do
      expect(Open3).to receive(:popen3).once.with('dwarfdump', '-u', 'path').and_return([nil, @arch_output, nil])
      expect(@symbolicator.architectures).to eql('i386' => '8436FEF6-2A0C-3395-91A5-55E7F5F1E6A2')
    end
  end

  describe "#symbols" do
    it "should parse the debug_info data" do
      expect(Open3).to receive(:popen3).once.with('dwarfdump', '--debug-info', '--arch=i386', 'path').and_return([nil, @info_output, nil])
      archs = @symbolicator.symbols('i386')
      expect(archs).to be_kind_of(Squash::Symbolicator::Symbols)
      expect(archs.size).to eql(209)
      sym = archs.for('0x00002661'.hex)
      expect(sym).not_to be_nil
      expect(sym.file).to eql('SquashTester/STViewController.m')
      expect(sym.line).to eql(50)
      expect(sym.ios_method).to eql("-[STViewController boomSignal:]")
      expect(sym.start_address).to eql('0x00002660'.hex)
      expect(sym.end_address).to eql('0x000026a7'.hex)
    end
  end

  describe "#lines" do
    it "should parse the debug_lines data" do
      expect(Open3).to receive(:popen3).once.with('dwarfdump', '--debug-line', '--arch=i386', 'path').and_return([nil, @line_output, nil])
      archs = @symbolicator.lines('i386')
      expect(archs).to be_kind_of(Squash::Symbolicator::Lines)
      expect(archs.size).to eql(1588)
      line = archs.for('0x00000000000020f0'.hex)
      expect(line).not_to be_nil
      expect(line.file).to eql('SquashTester/STAppDelegate.m')
      expect(line.line).to eql(36)
      expect(line.column).to eql(1)
      expect(line.start_address).to eql('0x00000000000020f0'.hex)
    end
  end
end
