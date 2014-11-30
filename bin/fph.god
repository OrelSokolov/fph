
@root = File.expand_path File.join(File.dirname(__FILE__), '../')

God.watch do |w|
  w.name = "fph"
  w.dir = "#{@root}"
  w.start = "bundle exec ruby #{@root}/bin/fph --log"
  w.log = "#{@root}/log/fph.log"
  w.keepalive
end
