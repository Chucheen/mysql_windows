mysql_windows_service "MySQL Server 5.0" do
  msi_url_path        'file://c:'
  msi_url_file        'mysql-essential-5.0.51a-winx64.msi'
end