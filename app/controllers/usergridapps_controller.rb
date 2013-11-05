require 'net/http'
require 'uri'
require 'json'
require 'map'
require 'usergrid_iron'

class UsergridappsController < MVCLI::Controller
  requires :compute
  requires :command

  def create
    template = Usergridapps::CreateForm
    argv = MVCLI::Argv.new command.argv
    form = template.new argv.options
    command.output.puts "Creating application on Usergrid server..."
    management = Usergrid::Management.new "http://#{server.ipv4_address}:8080"
    management.login form.admin_username, form.admin_password
    organization = management.organization form.org_name
    #fail organization.response.inspect
    begin
      organization.create_application form.app_name
      #command.output.puts application.inspect
      command.output.puts "Organization name: #{form.org_name}"
      command.output.puts "Application name: #{form.app_name}"
    rescue
      command.output.puts "Something went wrong. Most likely the application already exists."
    end
    #fail application.response.inspect
    return server
  end

  private

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end
