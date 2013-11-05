class Usergridapps::CreateForm < MVCLI::Form

  input :org_name, String, default: 'my_organization'
  input :app_name, String, default: 'my_app'
  input :admin_username, String, default:'my_org_admin'
  input :admin_password, String, default: 'admin_pass'
end
