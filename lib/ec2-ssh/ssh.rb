module Ec2Ssh::Cli::Ssh
  def set_ssh(user, pty)
    ENV['SSHKIT_COLOR'] = 'TRUE'
    SSHKit.config.output_verbosity = Logger::DEBUG
    ssh_options = {
        :user => user,
        :paranoid => false,
        :forward_agent => true,
        :user_known_hosts_file => '/dev/null'
    }

    SSHKit::Backend::Netssh.configure { |ssh|
      ssh.ssh_options = ssh_options
      ssh.pty = true if pty
    }


  end

  def ssh_to(user, dsl_options, cmd, capture_output, upload, download)
    say "Running #{cmd} via ssh in #{dsl_options}", color = :cyan
    on @all_servers, dsl_options  do |host|
     
      if upload
        file = upload.split(',').map { |e| e.strip }
        source = File.expand_path(file.first)
        destination = file.last
        puts "uploading #{source} to #{destination}..."
        upload! source, destination
      end

      if download
        file = download.split(',').map { |e| e.strip }
        source = file.first
        destination = File.expand_path(file.last)
        puts "downloading #{source} to #{destination}..."
        download! source, destination
      end

      if capture_output 
        puts capture cmd
      elsif upload.nil? && download.nil?
        execute cmd
      end
    end
  end
end