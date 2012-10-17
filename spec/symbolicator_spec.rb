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

describe Squash::Symbolicator do
  before :all do
    @symbolicator = Squash::Symbolicator.new('path', '/Users/tim/Desktop/SquashTester')
    @arch_output  = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'arch_output.txt'))
    @info_output  = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'info_output.txt'))
    @line_output  = File.read(File.join(File.dirname(__FILE__), 'fixtures', 'line_output.txt'))
  end

  describe "#architectures" do
    it "should return a hash of architectures" do
      Open3.should_receive(:popen3).once.with('dwarfdump', '-u', 'path').and_return([nil, @arch_output, nil])
      @symbolicator.architectures.should eql('i386' => '4ACE372B-AA78-37CD-8B88-500471BDC913')
    end
  end

  describe "#symbols" do
    it "should parse the debug_info data" do
      Open3.should_receive(:popen3).once.with('dwarfdump', '--debug-info', '--arch=i386', 'path').and_return([nil, @info_output, nil])
      archs = @symbolicator.symbols('i386')
      archs.should be_kind_of(Squash::Symbolicator::Symbols)
      archs.size.should eql(190)
      sym = archs.for('0x00002ea0'.hex)
      sym.should_not be_nil
      sym.file.should eql('SquashTester/STViewController.m')
      sym.line.should eql(50)
      sym.method.should eql("-[STViewController boomSignal:]")
      sym.start_address.should eql('0x00002ea0'.hex)
      sym.end_address.should eql('0x00002ee7'.hex)
    end
  end

  describe "#lines" do
    it "should parse the debug_lines data" do
      Open3.should_receive(:popen3).once.with('dwarfdump', '--debug-line', '--arch=i386', 'path').and_return([nil, @line_output, nil])
      archs = @symbolicator.lines('i386')
      archs.should be_kind_of(Squash::Symbolicator::Lines)
      archs.size.should eql(1437)
      line = archs.for('0x0000000000002930'.hex)
      line.should_not be_nil
      line.file.should eql('SquashTester/STAppDelegate.m')
      line.line.should eql(36)
      line.column.should eql(1)
      line.start_address.should eql('0x0000000000002930'.hex)
    end
  end
end