class Jenkins::CreateForm < MVCLI::Form
  requires :naming

  input :git_repo, String, default: 'git@github.com:hayesmp/railsgirls-app.git'
  input :command, String, default: 'bundle exec rake'
  input :job, String, default: 'job1'

end
