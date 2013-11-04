require 'erubis'

class RailsificationsController < MVCLI::Controller
  requires :compute
  requires :naming
  requires :command
  requires :chefsolo

  def create
    command.output.puts "Setting up a chef kitchen in order to railsify your server."
    command.output.puts "This could take a while...."
    sleep(1)
    chef_server = chefsolo.pipeline(server, [{:name=>"rackbox", :repo=>"hayesmp/rackbox-cookbook"}], load_runlist)
    return chef_server
  end

  private

  def load_runlist
  run_list = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../views/railsifications/run_list.json.erb"))
  run_list = Erubis::Eruby.new(run_list)
  run_list.result()
  end

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end
