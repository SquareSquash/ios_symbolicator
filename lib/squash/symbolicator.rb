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

require 'open3'

module Squash

  # Uses `dwarfdump` to generate symbolication information for a given dSYM
  # file. Uses `POpen3` to shell out to `dwarfdump`.

  class Symbolicator

    # Creates a new symbolicator for a given dSYM file.
    #
    # @param [String] dsym The path to a dSYM file (or DWARF file within).
    # @param [String] project_dir The path to a project root that will be removed
    #   from file paths underneath that root.

    def initialize(dsym, project_dir=nil)
      @dsym        = dsym
      @project_dir = project_dir
    end

    # @return [Hash<String, String>] A hash mapping architectures (such as "i386")
    #   to the UUID for the symbolication of that architecture.

    def architectures
      architectures = Hash.new

      stdin, stdout, stderr = Open3.popen3('dwarfdump', '-u', @dsym)
      stdout.each_line do |line|
        if line =~ /^UUID: ([0-9A-F\-]+) \((.+?)\) [^\s]+$/
          architectures[$2] = $1
        end
      end

      return architectures
    end

    # Extracts symbol information from the dSYM.
    #
    # @param [String] arch The architecture to extract symbols for.
    # @return [Symbols] The symbols defined in the dSYM.
    # @see #architectures

    def symbols(arch)
      symbolications     = Symbols.new
      current_subprogram = nil

      stdin, stdout, stderr = Open3.popen3('dwarfdump', '--debug-info', "--arch=#{arch}", @dsym)
      stdout.each_line do |line|
        if current_subprogram
          if line =~ /^\s*AT_(\w+)\(\s*(.+?)\s*\)$/
            tag   = $1
            value = $2

            case tag
              when 'name', 'decl_file' # quoted strings
                value = value[1..-2]
              when 'decl_line' # decimal integers
                value = value.to_i
              when 'prototyped', 'external' # booleans
                value = (value == '0x01')
              when 'low_pc', 'high_pc' # hex integers
                value = value.hex
            end

            current_subprogram[tag] = value
          elsif line =~ /^0x[0-9a-f]+:\s+TAG_(\w+)/
            current_subprogram['decl_file'].sub!(/^#{Regexp.escape @project_dir}\//, '') if @project_dir
            symbolications.add current_subprogram['low_pc'],
                               current_subprogram['high_pc'],
                               current_subprogram['decl_file'],
                               current_subprogram['decl_line'],
                               current_subprogram['name']

            current_subprogram = ($1 == 'subprogram') ? Hash.new : nil
          end
        else
          if line =~ /^0x[0-9a-f]+:\s+TAG_subprogram\s+\[\d+\]\s+\*$/
            current_subprogram = Hash.new
          end
        end
      end

      return symbolications
    end

    # Extracts line number information from the dSYM.
    #
    # @param [String] arch The architecture to extract symbols for.
    # @return [Symbols] The line info defined in the dSYM.
    # @see #architectures

    def lines(arch)
      lines        = Lines.new
      current_line = nil

      stdin, stdout, stderr = Open3.popen3('dwarfdump', '--debug-line', "--arch=#{arch}", @dsym)
      stdout.each_line do |line|
        if current_line
          if line =~ /^include_directories\[\s+(\d+)\] = '(.+)'$/
            current_line[:include_directories][$1] = $2
          elsif line =~ /^file_names\[\s*(\d+)\]\s+(\d+)\s+0x[0-9a-f]+\s+0x[0-9a-f]+\s+(.+)$/
            current_line[:file_names][$1] = current_line[:include_directories][$2] + '/' + $3
          elsif line =~ /^            (0x[0-9a-f]+)\s+(\d+)\s+(\d+)\s+(\d+)\s+/
            path          = current_line[:file_names][$2]
            line          = $3.to_i
            col           = $4.to_i
            start_address = $1.hex
            path.sub!(/^#{Regexp.escape @project_dir}\//, '') if @project_dir
            lines.add start_address, path, line, col
          end
        else
          if line =~ /^debug_line\[0x[0-9a-f]+\]$/
            current_line = {
                :include_directories => {},
                :file_names          => {}
            }
          end
        end
      end

      return lines
    end
  end
end

require 'squash/symbolicator/lines'
require 'squash/symbolicator/symbols'
