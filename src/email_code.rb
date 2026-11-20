def email_decode(line)
  return nil unless line
  line.gsub(/[^\s!]+![^\s!]+/) { |email| email.sub('!', '@') }
end

# "affiliation" lines of a pretty JSON are kept: they hold company names (like Hack@Brown), not emails
def email_encode(line)
  return nil unless line
  line.gsub(/^([ \t]*"affiliation": .*)$|[^\s@]+@[^\s@]+/) { |email| $1 ? email : email.sub('@', '!') }
end

