## Using the Rumm Jenkins plug-in

The Rumm Jenkins plug-in system is designed to provide a quick up-and-running Jenkins CI (Continuous Integration) server on a Rackspace server instance.

Continuous Integration, according to Wikipedia, is the practice, in software engineering, of merging all developer working copies with a shared mainline several times a day. Jenkins, in concert with an SCM (Source Control Manager) can perform tasks each time updated code is added to the SCM.

The Rumm Jenkins tool `install jenkins on server :id` sets up Jenkins on the server instance and `create job on server :id'` creates a new Jenkins job.

This tool is primarily designed to work with Ruby or Rails projects. When you create a job, you can specify a command, otherwise `rake` will run as the default.

#Installation

First we'll create a new Rackspace server instance:

    rumm create server --name jenkins-server

      --> bootstrapping server jenkins-server
          done.
      created server: jenkins-server
        id: 09cdb2a2-0266-41be-bbb-2b031d258b5b, password: iLbUhhh8F98D

Then we'll setup jenkins on the server:

    rumm install jenkins on server jenkins-server

      Setting up a chef kitchen in order to install jenkins on your server.
      This could take a while....

      etc..
      jenkins installed on server jenkins-server: 192.237.240.111

This process will take about 10 minutes.
###Note: You can set your git credentials by passing 'git-name' and 'git-email' with this command. Otherwise your name and email will be set to [Jenkins, admin@jenkins.com].

    rumm install jenkins on server jenkins-server --git_name Grover Cleveland --git_email grover@whitehouse.gov

      Setting up a chef kitchen in order to install jenkins on your server.
      This could take a while....

      etc..
      jenkins installed on server jenkins-server: 192.237.240.111

##Setup your job to receive Webhooks from Github (Optional)

This step is optional, but a nice upgrade. If you want Jenkins to automatically build and run your command when you commit new code to a repository, you can setup a webhook your server's ip address on github.

Go to `Github -> Your repository -> Settings -> Service Hooks -> Jenkins(Github plugin)` or `https://github.com/<username>/<git repository>/settings/hooks`

In the text box add: `http://192.237.240.111:8080/github-webhook/`, select `Active` and click `Update Settings`.

##Create A New Job

Once setup is complete, you will be able to create a new job on the server.

The rumm jenkins plugin is designed to pull a Ruby or Rails project from a Git repository and build the latest updates. It will also run a command such as `rake` (the default) to run tests or whatever your heart desires.

If the command is run with no parameters, it with insert default values for the Git repository, job name and command (which could be changed later in the Jenkins Dashboard).

    rumm create job on server :id --job_name rails-girls-job --job_repo https://github.com/hayesmp/railsgirls-app.git --job_command rake

      Setting up new jenkins job: rails-girls-job on server: jenkins-server.
      new jenkins job created on server jenkins-server: 192.237.240.111

####Note: the Git repository must be in the `https` url format.

#Useage

If you setup a webhook with Github, all you need to do now is push to your repository and be done with it.

##The Jenkins Dashboard

While not strictly necessary to control jenkins, you might want to change or add settings, see why builds failed, do other stuff.

In your web browser, head to:

    http://192.237.240.111:8080

##Setting Up Email Notification

You may wish to setup an email so you can be notified of a build failure.

Head over to the jenkins configuration page: `Jenkins -> Manage Jenkins -> Configure System` or head to `http://192.237.240.111:8080/configure`.

Near the bottom of the page, head to the section `E-mail Notification` and enter smtp information and an email address.
