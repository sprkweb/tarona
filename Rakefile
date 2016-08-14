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

task :spec do
  sh 'rspec'
end

task new_version: [:doc, :spec] do
  print 'The documentation and the specs are in order? '
  next unless yes?
  version = get_version
  print 'I recommend you to check whether all the changes are work once again. '
  next unless yes?
  print 'Are you sure? '
  next unless yes?
  print 'You can not cancel it if you do not stop now. '
  next unless yes?
  print 'I do not recommend do it fast. You would better stop this now, then you should think some time whether'
  print ' it is ready for new version and then you may publish it. Are you sure want to continue? '
  next unless yes?
  print 'Now, if you are sure want to do it... Are you sure, aren\'t you?'
  next unless yes?
  puts 'You should update the version.rb file.'
  puts 'Then you can run the commands below:'
  puts "  $ git commit -m 'v#{version}'"
  puts "  $ git tag v#{version}"
  puts '  $ git checkout master (you are now on the dev branch, aren\'t you?)'
  puts '  $ git merge dev'
  puts '  $ git push origin master'
  puts '  $ gem build tarona.gemspec'
  puts "  $ gem push tarona-#{version}.gem"
end