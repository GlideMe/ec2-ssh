module Ec2Ssh::Cli::Ssh
  def set_ssh(user)
    ENV['SSHKIT_COLOR'] = 'TRUE'
    SSHKit.config.output_verbosity = Logger::DEBUG
    SSHKit::Backend::Netssh.configure { |ssh|
      ssh.ssh_options = {
        :user => user,
        :paranoid => false,
        :forward_agent => true,
        :user_known_hosts_file => '/dev/null'
      }
    }
  end

  def ssh_to(user, dsl_options, cmd, capture_output)
    say "Running #{cmd} via ssh in #{dsl_options}", color = :cyan
    on @all_servers, dsl_options  do |host|
      if capture_output
        puts capture cmd
      else
        execute cmd
      end
    end
  end
end