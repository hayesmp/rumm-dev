class Usergridorgs::CreateForm < MVCLI::Form
  requires :naming

  input :org_name, String, default: 'my_organization'
  input :admin_username, String, default:'my_org_admin'
  input :admin_name, String, default: 'MyOrgAdmin'
  input :admin_email, String, default: 'my_org_admin@usergrid.com'
  input :admin_password, String, default: 'admin_pass'

end
