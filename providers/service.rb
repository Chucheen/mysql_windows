def whyrun_supported?
	true
end

action :install do
	installation_name = new_resource.installation_name
	installer_url_path = new_resource.msi_url_path
	installer_url_file = new_resource.msi_url_file
	installation_path = new_resource.installation_path
	installation_path ||= "C:\\Program Files\\MySQL\\MySQL Server 5.0"
	root_password = new_resource.root_password
	ENV['MYSQL_PATH'] = installation_path

	remote_file "#{Chef::Config[:file_cache_path]}\\#{installer_url_file}" do
		source "#{installer_url_path}/#{installer_url_file}"
		not_if {::File.exists?("#{Chef::Config[:file_cache_path]}\\#{installer_url_file}")}
	end

	installer_filename = installer_url_file
	
	
	windows_package "#{installation_name}" do
		source "#{Chef::Config[:file_cache_path]}\\#{installer_filename}"
		options "INSTALLDIR=\"#{installation_path}\""
		action :install
		not_if {::Dir.exists?("#{installation_path}\\bin")}
	end

	env "MYSQL_PATH" do
		value "#{installation_path}"
	end

	windows_path "#{installation_path}\\bin" do
		action :add
	end

	windows_batch "Installing Service" do
		code <<-EOH
			set MYSQL_PATH="#{installation_path}"
			call %MYSQL_PATH%\\bin\\mysqld-nt.exe --install MySQL
		EOH
	end

	service "MySQL" do
		action :start
	end

	service "MySQL" do
		action :enable
	end

	ruby_block "Changing password for root" do
		block do
			command_response = Mixlib::ShellOut.new("\"#{installation_path}\\bin\\mysql.exe\" -u root --execute \"exit\"")
			command_response.run_command
			if !(command_response.stderr.include?('ERROR 1045'))
				# In order to allow the service to completely start and then change the passowrd
				# 
				sleep 30
				change_pass_str = "\"#{installation_path}\\bin\\mysql.exe\" -u root --execute \"UPDATE mysql.user SET Password=PASSWORD('#{root_password}') WHERE User='root';FLUSH PRIVILEGES;\""
				command_response = Mixlib::ShellOut.new(change_pass_str)
				command_response.run_command
				if(command_response.stderr.length > 0)
					raise ArgumentError, "An error ocurred trying to set the password. STDERR: #{command_response.stderr}"
				end
				puts "\nPassword has been set!"
				Chef::Log.info("Password has been set!");
				
			else
				puts "\nPassword wasn't changed since root already have a password defined. Maybe there's still data from a previous installation."
				Chef::Log.info("Password wasn't changed since root already have a passwod defined. Maybe there's still data from a previous installation.");
			end

			# This command is put in order to set exit status to 0 if mysql throwed 1, as in resources executed after this
			# may get the exit status as theirs. This has happened with subversion resources.
			#`dir`
			
		end
		not_if {root_password.nil?}
	end

	new_resource.updated_by_last_action(true)

end


action :uninstall do
	installation_name = new_resource.installation_name
	installer_url_path = new_resource.msi_url_path
	installer_url_file = new_resource.msi_url_file
	installation_path = new_resource.installation_path
	installation_path ||= "C:\\Program Files\\MySQL\\MySQL Server 5.0"

	installer_filename = installer_url_file

	remote_file "#{Chef::Config[:file_cache_path]}\\#{installer_url_file}" do
		source "#{installer_url_path}/#{installer_url_file}"
		not_if {::File.exists?("#{Chef::Config[:file_cache_path]}\\#{installer_url_file}")}
	end

	windows_batch "Uninstalling MySQL Server" do
		code <<-EOH
			msiexec /uninstall "#{Chef::Config[:file_cache_path]}\\#{installer_filename}" /quiet
		EOH
		not_if {!::Dir.exists?("#{installation_path}\\bin")}
	end

	ruby_block "Uninstalling service " do
		block do 
			status = `sc delete MySQL`
			Chef::Log.debug status.include?('FAIL') ? "Service was deleted already" : "Service removed"

			::FileUtils.remove_dir('C:\ProgramData\Microsoft\Windows\Start Menu\Programs\MySQL', true)
		end
	end

	ruby_block "Removing MySQL remaining folders #{"(Full uninstallation was selected, data is going to be removed)" if node[:mysql_windows][:lwrp][:remove_completely]}" do
		block do
			::FileUtils.remove_dir(installation_path, true) if node[:mysql_windows][:lwrp][:remove_completely]
		end
	end

	new_resource.updated_by_last_action(true)
end
