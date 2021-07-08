#!/usr/bin/env ruby
# frozen_string_literal: true

domain_diff = `git diff origin/master...HEAD entries/ | sed -n 's/^+.*"domain"[^"]*"\\(.*\\)".*/\\1/p'`
url_diff = `git diff origin/master...HEAD entries/ | sed -n 's/^+.*"url"[^"]*"\\(.*\\)".*/\\1/p'`
status = 0

domain_diff.split("\n").each do |site|
  next if url_diff.include?(site)

  puts `curl -sSI https://#{site}/`
  status = 1 unless $CHILD_STATUS
end
url_diff.split("\n").each do |site|
  puts `curl -sSI #{site}`
  status = 1 unless $CHILD_STATUS
end

exit(status)
