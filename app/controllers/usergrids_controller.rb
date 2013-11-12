require 'erubis'
require 'net/http'
require 'net/ssh'
require 'uri'

class UsergridsController < MVCLI::Controller
  requires :compute
  requires :naming
  requires :command
  requires :chefsolo

  def create
    template = Jenkins::CreateForm
    argv = MVCLI::Argv.new command.argv
    form = template.new argv.options
    command.output.puts "Setting up a chef kitchen in order to install usergrid on your server."
    command.output.puts "This could take a while...."
    sleep(1)
    chef_server = chefsolo.pipeline(server,
                                    [{:name => "usergridbox", :repo => "hayesmp/usergridbox-cookbook"}],
                                    load_runlist(form.git_name, form.git_email))
    return chef_server
  end

  def update
    command.output.puts "Initializing cassandra database..."
    Net::SSH.start("#{server.ipv4_address}", "root") do |ssh|
      ssh.exec! "/var/chef/cache/dsc-cassandra-1.1.11/bin/cassandra"
    end
    uri = URI.parse("http://#{server.ipv4_address}:8080/system/database/setup")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Get.new(uri.request_uri)
    request.basic_auth("admin", "admin_pass")
    response = http.request(request)
    if response.code == "200"
      return server
    else
      command.output.puts "Something went wrong. Response code: #{response.code}"
    end
  end

  private

  def load_runlist(git_name, git_email)
    run_list = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../views/usergrids/run_list.json.erb"))
    run_list = Erubis::Eruby.new(run_list)
    run_list.result()
  end

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end
