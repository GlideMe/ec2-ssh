#!/usr/bin/env ruby
# encoding: utf-8
$:.unshift File.expand_path(File.join(File.dirname(__FILE__), %w[.. lib]))

require 'aws-sdk'
require 'thor'
require 'pp'
require 'sshkit'
require 'sshkit/dsl'

class Ec2Ssh::Cli  < Thor
  include Thor::Actions
  autoload :Aws,            'ec2-ssh/aws'
  autoload :Ssh,            'ec2-ssh/ssh'
  autoload :Utils,          'ec2-ssh/utils'

  default_task :connect

  desc "connect", "Connect to autoscale instance (random instance), Pass --cmd='whatever' to run a cmd on the server (use ; to seperate commands)"
  method_option :cmd,                              :desc => 'commmand to run on remote servers'
  method_option :profile,                          :desc => 'Aws cli profile name as listed in ~/aws/credentials', :default => 'default'
  method_option :region,                           :desc => "region", :default => 'us-east-1'
  method_option :user,            :aliases => 'u', :desc => 'run as user', :default => 'ec2-user'
  method_option :parallel,        :aliases => 'p', :desc => 'run in parallel'
  method_option :sequence,        :aliases => 's', :desc => 'run in sequence'
  method_option :groups,          :aliases => 'g', :desc => 'run in groups'
  method_option :groups_limit,    :aliases => 'l', :desc => 'limit', :type => :numeric
  method_option :wait,            :aliases => 'w', :desc => 'wait',  :type => :numeric
  method_option :as,                               :desc => 'filter by autoscale groups'
  method_option :tag_key,                          :desc => 'tag key to filter instances by', :default => 'Name'
  method_option :tag_value,                        :desc => 'tag value to filter instances by'
  method_option :terminal,        :aliases => 't', :desc => 'open terminal tabs for all servers'
  method_option :capture_output,  :aliases => 'c', :desc => 'capture output'
  def connect
    extend Aws
    extend Ssh
    extend Utils
    set_ssh(options[:user])
    aws_init(options[:profile], options[:region])
      
    if options[:as]
      get_auto_scale_groups
    elsif options[:tag_value]
      get_instances(options[:tag_key].chomp, options[:tag_value].chomp)
    else
      say "No value provided for filtering instances", color = :red
      Ec2Ssh::Cli.start(%w{help connect})
      exit
    end
    
    if options[:terminal]
      open_in_terminal
    else

      if options[:parallel] && options[:sequence]
        say "You can't run both in sequence and in parallel at the same time"
        exit 1
      end

      mode = :parallel if options[:parallel]
      mode = :groups   if options[:groups]
      mode = :sequence if options[:sequence]

      mode = :parallel if mode.nil? 
      dsl_options = {}
      dsl_options[:in] = mode
      dsl_options[:wait]  = options[:wait] if options[:wait]
      dsl_options[:limit] = options[:groups_limit] if options[:groups_limit]
      
      say "dsl opts: #{dsl_options}", color = :cyan
      ssh_to(options[:user], dsl_options, options[:cmd], options[:capture_output])
    end
  end

  map ["-v", "--version"] => :version
  desc "version", "version"
  def version
    say Ec2Ssh::ABOUT, color = :green
  end  

end