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

def test(svg_content, xpath_expression, parent_element = '/svg')
  # Parse the SVG content
  !Nokogiri::XML(svg_content).remove_namespaces!.xpath("#{parent_element}#{xpath_expression}").empty?
end

@status = 0
diff = `git diff --name-only --diff-filter=Ard origin/master...HEAD -- 'img/***.svg'`.split("\n")
diff.each do |file|
  svg = File.read(file)
  error(file, 'Invalid SVG file') if Nokogiri::XML(svg).errors.any?
  error(file, 'Unnecessary processing instruction found') if svg.include? '<?'
  error(file, 'Embedded image detected') if test(svg, '//image')
  error(file, 'Minimize file to one line') if File.foreach(file).count > 1
  warn(file, 'Remove comments') if test(svg, '//comment()', '')
  warn(file, 'Unusually large file size') if File.size(file) > 5 * 1024
  warn(file, 'Unnecessary data attribute') if test(svg, '//*[starts-with(name(@*), "data-")]')
  warn(file, 'Use viewBox instead of height/width') if test(svg, '[@width or @height]')
  warn(file, 'Unnecessary id or class attribute in root element') if test(svg, '[@id or @class]')
  warn(file, 'Unnecessary fill="#000" attribute') if test(svg, '//path[@fill="#000"]')
  warn(file, 'Use Attributes instead of style elements') if test(svg, '//*[style]')
  warn(file, 'Use hex color instead of fill-opacity') if test(svg, '//*[@fill-opacity]')
  warn(file, 'Unnecessary XML:space declaration found') if svg.include? 'xml:space'
  if test(svg, '//*[@version or @class or @fill-rule or @script or @a or @style or @clipPath]')
    warn(file, 'Unnecessary attribute(s) found')
  end
end

exit @status
