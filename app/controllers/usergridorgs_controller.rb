require 'net/http'
require 'uri'
require 'json'

class UsergridorgsController < MVCLI::Controller
  requires :compute
  requires :command

  def create
    template = Usergridorgs::CreateForm
    argv = MVCLI::Argv.new command.argv
    @form = template.new argv.options
    command.output.puts "Creating organization on Usergrid server..."
    uri = URI.parse("http://#{server.ipv4_address}:8080/management/organizations")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"organization" => @form.org_name, "name" => @form.admin_name,
                            "username" => @form.admin_username, "email" => @form.admin_email,
                            "password" => @form.admin_password})
    response = http.request(request)
    #command.output.puts response.body.inspect
    if response.code == "200"
      command.output.puts "Organization: #{@form.org_name}"
      command.output.puts "Admin Name: #{@form.admin_name}"
      command.output.puts "Admin Username: #{@form.admin_username}"
      command.output.puts "Admin Email: #{@form.admin_email}"
      command.output.puts "Admin Password: #{@form.admin_password}"

      login_admin
    elsif response.code == "400"
      command.output.puts "Organization already exists. Logging in."
      login_admin
    else
      command.output.puts "Something went wrong: create organization. Response code: #{response.code}"
    end
    return server
  end

  private

  def login_admin
    uri = URI.parse("http://#{server.ipv4_address}:8080/management/token")
    http = Net::HTTP.new(uri.host, uri.port)
    request = Net::HTTP::Post.new(uri.request_uri)
    request.set_form_data({"grant_type" => "password", "username" => @form.admin_username,
                            "password" => @form.admin_password})
    response = http.request(request)
    #command.output.puts response.body.inspect
    parsed = JSON.parse(response.body)
    if response.code == "200"
      command.output.puts "Admin User auth token: #{parsed['access_token']}"
    else
      command.output.puts "Something went wrong: login admin user. Response code: #{response.code}"
    end
  end

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end
