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
    application = organization.create_application form.app_name

    uri = URI.parse("http://#{server.ipv4_address}:8080/management/orgs/#{form.org_name}/apps")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri, {'Authorization' => 'Bearer #{form.auth_token}', 'Content-Type' => 'application/json'})
    request.set_form({"name" => form.app_name})
    command.output.puts uri.request_uri
    response = http.request(request)
    command.output.puts response.body.inspect
    if response.code == "200"
      command.output.puts "Organization name: #{form.org_name}"
      command.output.puts "Application name: #{form.app_name}"
      command.output.puts "Management auth token: #{form.auth_token}"

      login_admin
    elsif response.code == "400"
      command.output.puts "Application already exists."
      login_admin
    else
      command.output.puts "Something went wrong: create application. Response code: #{response.code}"
    end
    return server
  end

  private

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end
