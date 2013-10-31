## Using the Rumm Usergrid plug-in

The Rumm Usergrid plugin is designed to quickly and easily spin up a backend server for a mobile app.

The `install usergrind on server :id` command sets up a node with everything you need to run Apigee's Usergrid service.

Then orginization, user and objects can be setup through the command-line tool. Apigee also provides SDKs for many popular platforms, including Android and iOS, that talk to the Usergrid service.

##Installation

First we'll create a new Rackspace server instance:

####Note: Usergrid needs a bit more memory than your average rails server, so we'll need to pass a `flavor_id` to the command

    rumm create server --name usergrid-server --flavor_id 3

      --> bootstrapping server usergrid-server
          done.
      created server: usergrid-server
        id: 09cdb2a2-0266-41be-bbb-2b031d258b5b, password: iLbUhhh8F98D

Then we'll setup usergrid on the server:

    rumm install usergrid on server usergrid-server

      Setting up a chef kitchen in order to install usergrid on your server.
      This could take a while....

      etc..
      usergrid installed on server jenkins-server: 192.237.240.111

This process will take about 10 minutes.

##Setup

First you need to create an admin account:

    curl -X POST  \
    -d 'name=admin&password=admin_pass' \
    http://166.78.250.91:8080/system/database/setup

With a clean usergrid setup we need to create a new organization and a master user.

    rumm create organization on usergrid server usergrid-server --org_name my_organization --user myuser --email myuser@ug.com --password pword

    organization created on usergrid server usergrid-server: 192.237.240.111

Now setup an application on the server:

    rumm create application on usergrid server usergrid-server --app_name my_application

    application created on usergrid server usergrid-server: 192.237.240.111
