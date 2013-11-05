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
    command.output.puts "Organization: #{@form.org_name}"
    command.output.puts "Admin Name: #{@form.admin_name}"
    command.output.puts "Admin Username: #{@form.admin_username}"
    command.output.puts "Admin Email: #{@form.admin_email}"
    command.output.puts "Admin Password: #{@form.admin_password}"

    if response.code == "400"
      command.output.puts "Organization or Andministrator already exists."
    else
      command.output.puts "Something went wrong:#{JSON.parse(response.body)['error']}  Response code: #{response.code}"
    end
    return server
  end

  private

  def server
    compute.servers.find {|s| s.name == params[:id]} or fail Fog::Errors::NotFound
  end
end
