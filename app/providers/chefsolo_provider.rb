require "tmpdir"
require "open3"
require "bundler"

class ChefsoloProvider
  requires :compute
  requires :naming
  requires :command

  def value
    self
  end

  def pipeline(server, cookbook_repo, run_list)
    tmpdir = Pathname(Dir.tmpdir).join 'chef_kitchen'
    FileUtils.mkdir_p tmpdir
    Dir.chdir tmpdir do
      Bundler.with_clean_env do
        File.open('Gemfile', 'w') do |f|
          f.puts 'source "https://rubygems.org"'
          f.puts 'gem "knife-solo", ">= 0.3.0pre3"'
          f.puts 'gem "berkshelf"'
        end
        execute "bundle install --binstubs"
        execute "bin/knife solo init ."
        FileUtils.rm "Berksfile"
        File.open 'Berksfile', 'w' do |f|
          f.puts "site :opscode"
          f.puts ""
          f.puts "cookbook 'runit', '>= 1.1.2'"
          cookbook_repo.each do |r|
            f.puts "cookbook '#{r[:name]}', github: '#{r[:repo]}'"
          end
        end
        execute "bin/berks install --path cookbooks/"
        execute "bin/knife solo prepare root@#{server.ipv4_address}"
        File.open('nodes/host.json', 'w') do |f|
          f.puts run_list
        end

        FileUtils.rm_rf "#{server.ipv4_address}.json"
        FileUtils.mv "nodes/host.json", "nodes/#{server.ipv4_address}.json"
        execute "bin/knife solo cook root@#{server.ipv4_address} -V"
      end
    end
    return server
  end

  private

  def execute(cmd)
    retried = 0
    begin
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        while line = stdout.gets
          command.output.puts "   " + line
        end
        exit_status = wait_thr.value
        unless exit_status.success?
          raise "FAILED !!! #{cmd}"
        end
      end
    rescue
      if retried < 3
        retried += 1
        sleep(1)
        retry
      end
    end
  end
end
