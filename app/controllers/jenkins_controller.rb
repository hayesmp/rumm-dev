require "tmpdir"
require "open3"
require "yaml"

class JenkinsController < MVCLI::Controller
  requires :compute
  requires :naming
  requires :command

  def create
    command.output.puts "Setting up a chef kitchen in order to railsify your server."
    command.output.puts "This could take a while...."
    sleep(1)
    tmpdir = Pathname(Dir.tmpdir).join 'chef_kitchen'
    FileUtils.mkdir_p tmpdir
    Dir.chdir tmpdir do
      File.open('Gemfile', 'w') do |f|
        f.puts 'source "https://rubygems.org"'
        f.puts 'gem "knife-solo", ">= 0.3.0pre3"'
        f.puts 'gem "berkshelf"'
      end
      #execute "bundle --system"
      #puts Dir.pwd
      puts ENV.inspect.to_yaml
      execute "bundle install --binstubs"
      execute "bin/knife solo init ."
      File.open 'Berksfile', 'w' do |f|
        f.puts "site :opscode"
        f.puts ""
        f.puts "cookbook 'runit', '>= 1.1.2'"
        f.puts "cookbook 'jenkins', github: 'hayesmp/jenkins-cookbook'"
      end
      execute "bin/berks install --path cookbooks/"
      execute "bin/knife solo prepare root@#{server.ipv4_address}"
      #File.open('nodes/host.json', 'w') do |f|
      #  f.puts('{"run_list":["rackbox"],"rackbox":{"apps":{"unicorn":[{"appname":"app1","hostname":"app1"}]},"ruby":{"global_version":"2.0.0-p195","versions":["2.0.0-p195"]}}}')
      #end

      #FileUtils.rm_rf "#{server.ipv4_address}.json"
      #FileUtils.mv "nodes/host.json", "nodes/#{server.ipv4_address}.json"

      execute "bin/knife solo cook root@#{server.ipv4_address}"
    end
    return server
  end

  def migrate_data(database_url)#mysql2://<username>:<password>@<dbinstance_hostname>/<database name>
    execute("scp db/development.sqlite3 root@#{server.ipv4_address}:/home/apps/app1/current/db/development.sqlite3")
    execute("ssh root@#{server.ipv4_address} 'cd /home/apps/app1/current/db && bundle exec taps server sqlite://development.sqlite3 templogin temppass -d & && bundle exec taps pull #{database_url} http://templogin:temppass@localhost:5000'")
  end

  private

  def execute(cmd)
    #puts Dir.pwd
    bundle_clean_env {
      Open3.popen3(cmd) do |stdin, stdout, stderr, wait_thr|
        while line = stdout.gets
          bundle_clean_env {} if cmd == 'bundle install --binstubs'
          command.output.puts "   " + line
        end
        exit_status = wait_thr.value
        unless exit_status.success?
          abort "FAILED !!! #{cmd}"
        end
      end
    }
  end

  def bundle_clean_env
    gemfile = ENV['BUNDLE_GEMFILE']
    bin_path = ENV['BUNDLE_BIN_PATH']
    ENV.delete 'BUNDLE_GEMFILE'
    ENV.delete 'BUNDLE_BIN_PATH'
    yield
  ensure
    ENV['BUNDLE_GEMFILE'] = gemfile
    ENV['BUNDLE_BIN_PATH'] = bin_path
    true
  end

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end