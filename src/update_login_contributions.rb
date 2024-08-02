#!/usr/bin/env ruby

# ./update_login_contributions.rb && JSON=affiliated.json ./update_login_contributions.rb && cp affiliated.json ../../devstats/github_users.json

require 'json'
require 'csv'
require 'pry'

def update_json(json_file, csv_file)
  dbg = !ENV['DBG'].nil?
  cnts = {}
  CSV.foreach(csv_file, headers: true) do |row|
    login = row['login'].downcase
    cnt = row['cnt'].to_i
    cnts[login] = cnt
  end
  data = JSON.parse File.read json_file
  updates = 0
  data.each_with_index do |row, i|
    login = row['login'].downcase
    cnt = row['commits'].to_i
    next unless cnts.key?(login)
    ncnt = cnts[login]
    next if ncnt <= cnt
    puts "update #{i} #{login} #{cnt} -> #{ncnt}" if dbg
    row['commits'] = ncnt
    updates += 1
  end
  if updates > 0
    data = data.sort_by { |u| [-u['commits'], u['login'], u['email']] }
    pretty = JSON.pretty_generate data
    File.write json_file, pretty
    puts "updated #{updates} entries in #{json_file}"
  else
    puts "everything up to date in #{json_file}"
  end
end

file_to_update = ENV['JSON'] || 'github_users.json'
update_json(file_to_update, 'login_contributions.csv')
