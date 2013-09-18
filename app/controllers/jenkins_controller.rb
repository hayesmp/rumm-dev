require "tmpdir"
require "open3"
require "bundler"

class JenkinsController < MVCLI::Controller
  requires :compute
  requires :naming
  requires :command

  def create
    template = Jenkins::CreateForm
    argv = MVCLI::Argv.new command.argv
    form = template.new argv.options
    command.output.puts "Setting up a chef kitchen in order to setup jenkins on your server."
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
      Bundler.with_clean_env { execute "bundle install --binstubs" }
      execute "bin/knife solo init ."
      FileUtils.rm "Berksfile"
      File.open 'Berksfile', 'w' do |f|
        f.puts "site :opscode"
        f.puts ""
        f.puts "cookbook 'runit', '>= 1.1.2'"
        f.puts "cookbook 'rackbox', github: 'hayesmp/jenkinsbox-cookbook'"
      end
      execute "bin/berks install --path cookbooks/"
      execute "bin/knife solo prepare root@#{server.ipv4_address}"
      File.open('nodes/host.json', 'w') do |f|
        f.puts("{\"run_list\":[\"rackbox\"],\"rackbox\":{\"jenkins\":{\"job\":\"#{form.job}\",\"git_repo\":\"#{form.git_repo}\",\"command\":\"#{form.command}\",\"ip_address\":\"#{server.ipv4_address}\", \"host\":\"#{server.name}\"},\"ruby\":{\"versions\":[\"2.0.0-p247\",\"1.9.3-p448\"],\"global_version\":\"2.0.0-p247\"}}}")
        #f.puts("{\"run_list\":[\"rackbox\"],\"rackbox\":{\"jenkins\":{\"job\":\"#{form.job}\",\"git_repo\":\"#{form.git_repo}\",\"command\":\"#{form.command}\"}}}")
      end

      FileUtils.rm_rf "#{server.ipv4_address}.json"
      FileUtils.mv "nodes/host.json", "nodes/#{server.ipv4_address}.json"
      #execute "hostname #{server.ipv4_address}"
      execute "bin/knife solo cook root@#{server.ipv4_address} -VV"
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