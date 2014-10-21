mysql_windows_password "Changing root password for the first time" do
	installation_path 'C:\Program Files\MySQL\MySQL Server 5.0'
	user_pass 'devtest'
	action :change_initial_root
end