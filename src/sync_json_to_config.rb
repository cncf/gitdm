#!/usr/bin/env ruby

require 'pry'
require 'json'

dbg = !ENV['DBG'].nil?
dry = !ENV['DRY'].nil?
all_logins = !ENV['ALL_LOGINS'].nil?
all_emails = !ENV['ALL_EMAILS'].nil?
all = all_logins or all_emails

email_map = 'cncf-config/email-map'
if ARGV.length == 0
  puts "Specify one or more logins to sync JSON -> config"
  puts "Example: lukaszgryglicki 'other_login:specific-email!domain.com' (for non-unique affiliations within login)"
  puts "Full usage: [DBG=1] [DRY=1] [ALL_LOGINS=1 | ALL_EMAILS=1] ./sync_json_to_config.rb login[:email] [login2[:email2] [...]]"
  exit 0 unless all
end

users = {}
dusers = {}
json_data = JSON.parse File.read 'github_users.json'
aff_key = 'affiliation'
a_logins = {}
a_emails = {}
json_data.each_with_index do |user, index|
  login = user['login'].strip
  a_logins[login] = true if all_logins
  dlogin = login.downcase
  email = user['email'].strip
  a_emails[email] = true if all_emails
  affiliations = user[aff_key].strip if user.key?(aff_key) and not user[aff_key].nil?
  users[login] = [] unless users.key?(login)
  users[login] << [email, affiliations]
  dusers[dlogin] = [] unless dusers.key?(dlogin)
  dusers[dlogin] << [login, email, affiliations]
end

emails = {}
File.readlines(email_map).each do |line|
  line.strip!
  if line.length > 0 && line[0] == '#'
    next
  end
  ary = line.split ' '
  email = ary[0]
  aff = ary[1..-1].join(' ')
  emails[email] = [] unless emails.key?(email)
  emails[email] << aff
end

changes = 0
ARGV.each do |login|
  ary = login.split ':'
  login = ary[0].strip
  dlogin = login.downcase
  mail = ary[1].strip if ary.length > 1 and not ary[1].nil?
  unless users.key? login
    puts "#{login} not found in JSON"
    if dusers.key? dlogin
      puts "but downcased #{dlogin} found, please use the correct case"
      puts "found #{dusers[dlogin]}"
    end
    next
  end
  data = users[login]
  affs = {}
  mails = []
  mmails = {}
  data.each do |row|
    mails << row[0]
    mmails[row[0]] = true
    if mail.nil? or row[0] == mail
      affs[row[1]] = true
    end
  end
  if affs.length == 0 
    puts "#{login} has no affiliations, cannot update"
    next
  end
  if affs.length > 1
    puts "#{login} has non-unique affiliations, cannot update"
    next
  end
  affs = affs.first[0]
  ary = affs.split ','
  ary.each_with_index do |_, i|
    ary[i].strip!
  end
  ary.sort!
  puts "checking login #{login} for #{mails.join(', ')} having #{ary.join(', ')}" if dbg
  mails.each do |mail|
    dmail = mail.downcase
    if !mmails.key?(dmail) and emails.key?(dmail)
      puts "downcased #{mail} present in config - will be removed"
      puts "to remove: #{dmail}: #{emails[dmail].sort.join(', ')}"
      emails.delete(dmail)
      changes += 1
    end
    unless emails.key? mail
      puts "#{mail} was not in config - added"
      emails[mail] = ary
      changes += 1
      next
    end
    if emails[mail].length != ary.length
      puts "#{mail} in config is different than JSON:"
      puts "config has: #{emails[mail].sort.join(', ')}"
      puts "JSON   has: #{ary.join(', ')}"
      emails[mail] = ary
      changes += 1
      next
    else
      curr = emails[mail].sort
      diff = false
      ary.each_with_index do |_, i|
        cfg = curr[i]
        jso = ary[i]
        unless cfg == jso
          puts "#{mail} in config is different than JSON for ##{i+1} affiliation:"
          puts "config has: #{curr.join(', ')}"
          puts "difference on: #{cfg}"
          puts "JSON   has: #{jso}"
          diff = true
          break
        end
      end
      if diff
        emails[mail] = ary
        changes += 1
        next
      end
      puts "#{mail} config is OK" if dbg
    end
  end
end
if changes > 0
  puts "made #{changes} changes" if dbg
  unless dry
    File.open(email_map, 'w') do |file|
      file.puts "# Here is a set of mappings of domain names onto employer names."
      file.puts "# [user!]domain  employer  [< yyyy-mm-dd]"
      emails.sort.each do |email, affs|
        affs.sort.each do |aff, _|
          file.puts "#{email} #{aff}"
        end
      end
    end
    puts "saved #{email_map}" if dbg
  else
    puts "not saving because of dry mode" if dbg
  end
end
