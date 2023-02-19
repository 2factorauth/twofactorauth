#!/usr/bin/env ruby
# frozen_string_literal: true

require 'json'
require 'active_support'
require 'active_support/core_ext/hash'
require 'nokogiri'

def error(file, msg)
  puts "::error file=#{file}:: #{msg}"
  @status = 1
end

def warn(file, msg)
  puts "::warning file=#{file}:: #{msg}"
end

def test(svg, css)
  svg.css(css).length.positive?
end

@status = 0
diff = `git diff --name-only --diff-filter=Ard origin/master...HEAD -- 'img/***.svg'`
diff.split("\n").each do |file|
  read = File.read(file)

  # Tests without XML parsing
  error(file, 'File should only contain an svg element') unless Hash.from_xml(read).keys.eql? ['svg']
  error(file, 'Embedded raster image detected') if read.include? 'data:image/'
  warn(file, 'Unusually large file size') if File.size(file) > 5 * 1024
  warn(file, 'Minimize file to one line') unless File.foreach(file).count <= 2
  warn(file, 'Unnecessary data attribute') if read.include? 'data-'

  # Parse XML of SVG
  svg = Nokogiri::XML(read) do |config|
    config.strict.noblanks
  end

  # Tests with XML parsing
  error(file, 'SVG contains syntax errors') if svg.errors.count.positive?
  error(file, 'xmlns attribute not defined') unless svg.namespaces['xmlns'].eql? 'http://www.w3.org/2000/svg'
  warn(file, 'SVG contains unnecessary attributes') if test(svg, '[version], [class], [fill-rule]')
  warn(file, 'SVG contains unnecessary elements') if test(svg, 'clipPath, script, a, style')
  warn(file, 'Use viewBox instead of height/width attributes') if test(svg, '[width], [height]')
  warn(file, 'Use hex color instead of fill-opacity') if test(svg, '[fill-opacity]')
  warn(file, 'Unnecessary fill="#000" attribute') if test(svg, "[fill='#000']")
  warn(file, 'Real coordinates preferred over transform attribute') if test(svg, '[transform] :not(use)')
end

exit @status
