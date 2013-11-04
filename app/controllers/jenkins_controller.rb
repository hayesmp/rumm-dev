require 'erubis'

class JenkinsController < MVCLI::Controller
  requires :compute
  requires :naming
  requires :command
  requires :chefsolo

  def create
    template = Jenkins::CreateForm
    argv = MVCLI::Argv.new command.argv
    form = template.new argv.options
    command.output.puts "Setting up a chef kitchen in order to install jenkins on your server."
    command.output.puts "This could take a while...."
    sleep(1)
    chef_server = chefsolo.pipeline(server, [{:name=>"jenkinsbox", :repo=>"hayesmp/jenkins-rackbox-cookbook"}], load_runlist(form.git_name, form.git_email))
    return chef_server
  end

  private

  def load_runlist(git_name, git_email)
    run_list = File.read(File.join(File.dirname(File.expand_path(__FILE__)), "../views/jenkins/run_list.json.erb"))
    run_list = Erubis::Eruby.new(run_list)
    run_list.result(:git_name => git_name, :git_email => git_email)
  end

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end