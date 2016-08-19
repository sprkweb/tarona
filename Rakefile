def yes?
  puts '[y/N]'
  gets.downcase[0] == 'y'
end

def get_version
  print 'New version is: v'
  version = gets.strip
  if version.match /\d+.\d+.\d+/
    puts 'It seems like the version is three numbers divided by dot. It is good.'
  else
    puts 'It seems like the version is not three numbers divided by dot. It is bad. Try again.'
    version = get_version
  end
  version
end

task :doc do
  sh 'yard'
end
