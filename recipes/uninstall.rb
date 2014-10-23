node.set[:mysql_windows][:lwrp][:remove_completely] = true

mysql_windows_service "MySQL Server 5.0" do
  msi_url_path        'http://s3.amazonaws.com/windows'
  msi_url_file        'mysql-essential-5.0.51a-winx64.msi'
  action              :uninstall
end
