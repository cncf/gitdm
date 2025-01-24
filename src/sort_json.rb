#!/usr/bin/env ruby

require 'json'
require 'date'
# require 'pry'

def sort_json(json_file)
  data = JSON.parse File.read json_file
  data = data.sort_by { |u| [-u['commits'], u['login'], u['email']] }
  data.each_with_index do |row, idx|
    affs = row['affiliation']
    # p affs
    next unless affs
    ary = affs.split(/\s*,\s*/)
    next if ary.length <= 1
    ary = ary.sort_by do |aff|
      ary2 = aff.split(/\s*<\s*/)
      dts = ary2.length >= 2 ? ary2[1] : '2100-01-01'
      # p dts
      Date.strptime(dts,"%Y-%m-%d").to_time.to_i
    end
    affs2 = ary.join(', ')
    if affs != affs2
      p [idx, row['login'], row['email']]
      puts affs
      puts affs2
      puts ''
      data[idx]['affiliation'] = affs2
    end
  end
  pretty = JSON.pretty_generate data
  File.write json_file, pretty
end

if ARGV.size < 1
  puts "Missing arguments: github_users.json"
  exit(1)
end

sort_json(ARGV[0])
