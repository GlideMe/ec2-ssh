module Ec2Ssh
  VERSION   = "1.0.2"
  ABOUT     = "ec2-ssh v#{VERSION} (c) #{Time.now.strftime("2015-%Y")} @innovia"

  $:.unshift File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib]))

  autoload :Cli,      'ec2-ssh/cli'
end