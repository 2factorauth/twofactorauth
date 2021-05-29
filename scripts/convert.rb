#!/usr/bin/env ruby
# frozen_string_literal: true

require 'yaml'
require 'json'
require 'uri'
require 'fileutils'

YAML.load_file('_data/sections.yml').each do |section|
  YAML.load_file("_data/#{section['id']}.yml")['websites'].each do |website|
    a = {}

    domain = URI(website['url']).host
    if domain.start_with?('www.')
      domain['www.'] = ''
      a['domain'] = domain
      a['url'] = website['url']
    else
      a['domain'] = domain
    end

    unless website['tfa'].nil?
      a['tfa'] = []
      website['tfa'].each do |method|
        method = 'call' if method == 'phone'
        method = 'custom-hardware' if method == 'hardware'
        method = 'custom-software' if method == 'proprietary'
        a['tfa'].push(method)
      end
    end

    unless website['email_address'].nil? && website['facebook'].nil? && website['twitter'].nil?
      contact = {}
      contact['email'] = website['email_address'] unless website['email_address'].nil?
      contact['facebook'] = website['facebook'] unless website['facebook'].nil?
      contact['twitter'] = website['twitter'] unless website['twitter'].nil?
      contact['language'] = website['lang'] unless website['lang'].nil?
      a['contact'] = contact
    end

    a['documentation'] = website['doc'] unless website['doc'].nil?
    a['notes'] = website['exception'] unless website['exception'].nil?
    a['keywords'] = [section['id']]
    a['regions'] = website['regions'] unless website['regions'].nil?

    output = {}
    output[website['name']] = a

    FileUtils.mkdir_p("entries/#{a['domain'][0].downcase}")
    FileUtils.mkdir_p("img/#{a['domain'][0].downcase}")
    File.open("entries/#{a['domain'][0].downcase}/#{a['domain'].downcase}.json", 'w') do |file|
      file.write JSON.pretty_generate(output)
    end
  end
end
