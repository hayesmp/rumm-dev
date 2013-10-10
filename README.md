## Rumm: a tasty tool for hackers and pirates

[![Gem Version](https://badge.fury.io/rb/rumm.png)](http://badge.fury.io/rb/rumm)
[![Build Status](https://travis-ci.org/rackerlabs/rumm.png?branch=master)](https://travis-ci.org/rackerlabs/rumm)
[![Dependency Status](https://gemnasium.com/rackerlabs/rumm.png)](https://gemnasium.com/rackerlabs/rumm)


Rumm is a command line interface and API to rackspace. You can use it
to easily build and manage infrastructure for great good.


## Usage

Authenticate with rackspace using your cloud credentials as follows:

    rumm login
      username: joe
      password: ****
      logged in, credentials written to ~/.netrc
      

Now we can see the list of servers we have available:

    $ rumm show servers
    you don't have any servers, but you can create one by running:
    rumm create server

Create the server:

    rumm create server
      created server divine-reef
        id: 52415800-8b69-11e0-9b19-734f565bc83b, password: <password>
        
For further help, including a full listing of commands, type:

    rumm help

## Create a Jenkins server

  The purpose of this rumm plug-in is to easily create a CI (continuous integration) server for a given project.
  The 'install jenkins' command will install and setup jenkins on a rumm-prepared server. The setup will create a job
  and given a git repository to pull from when a webhook shows a new commit has been made.
  The user will specify a build command.

  create a server

    rumm create server
      created server divine-reef
        id: 52415800-8b69-11e0-9b19-734f565bc83b, password: <password>


  install Jenkins

    rumm install jenkins on server divine-reef --build-command 'bundle exec rake'
      jenkins installed on server divine-reef: 67.23.10.138


## Further Reading

See the [official rumm website][1] for more information, including documentation.

[1]: http://rackerlabs.github.io/rumm
