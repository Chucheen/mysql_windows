
mysql_windows_service "MySQL Server 5.0" do
  msi_url_path        'http://devfactory-user-data.s3.amazonaws.com/packages/MySQL/windows'
  msi_url_file        'mysql-essential-5.0.51a-winx64.msi'
  remove_completely	  false
  action              :uninstall
end