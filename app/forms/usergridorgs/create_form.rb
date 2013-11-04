class Usergridorgs::CreateForm < MVCLI::Form
  requires :naming

  input :org_name, String, default: 'My Organization'
  input :admin_username, String, default: 'admin'
  input :admin_name, String, default: 'Admin'
  input :admin_email, String, default: 'admin@usergrid.com'
  input :admin_password, String, default: 'admin_pass'

end
