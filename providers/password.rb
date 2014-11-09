action :change do 
  if(@current_resource.updated_already)
    Chef::Log.info('Password was already updated. Nothing to do here...')
    new_resource.updated_by_last_action(false)
  else
    exec_user_name = @current_resource.execution_user_name
    exec_user_pass = @current_resource.execution_user_pass
    user_name = @current_resource.user_name
    user_pass = @current_resource.user_pass
    validate_parameters(@current_resource.action, exec_user_name, exec_user_pass, user_name, user_pass)
    updated = execute_mysql_command(exec_user_name, exec_user_pass, user_name, user_pass)
    new_resource.updated_by_last_action(updated)
  end
end

action :change_initial_root do
  if(@current_resource.updated_already)
    Chef::Log.info('Password was already updated. Nothing to do here...')
    new_resource.updated_by_last_action(false)
  else
    exec_user_name = 'root'
    exec_user_pass = ''
    user_name = 'root'
    user_pass = @current_resource.user_pass
    validate_parameters(@current_resource.action, exec_user_name, exec_user_pass, user_name, user_pass)
    updated = execute_mysql_command(exec_user_name, exec_user_pass, user_name, user_pass)
    new_resource.updated_by_last_action(updated)
  end
end

def load_current_resource
  @current_resource = Chef::Resource::MysqlWindowsPassword.new(@new_resource.name)
  @current_resource.execution_user_name(new_resource.execution_user_name)
  @current_resource.execution_user_pass(new_resource.execution_user_pass)
  @current_resource.user_name(new_resource.user_name)
  @current_resource.user_pass(new_resource.user_pass)
  @current_resource.installation_path(new_resource.installation_path)
  @current_resource.updated_already = password_is_updated
end

private
  def exe_path
    installation_path = @current_resource.installation_path
    installation_path = installation_path.nil? ? 'mysql.exe' : (installation_path[installation_path.length - 3..-1] == 'bin' ? "#{installation_path}\\mysql.exe" : "#{installation_path}\\bin\\mysql.exe")
    "\"#{installation_path}\""
  end

  def execute_mysql_command(exec_user_name, exec_user_pass, user_name, user_pass)
    exe = exe_path
    shellout = Mixlib::ShellOut
    command_str = "#{exe} -u #{exec_user_name} #{exec_user_pass.length > 0 ? "-p#{exec_user_pass}" : ""}"
    command_str = "#{command_str} --execute \"UPDATE mysql.user SET Password=PASSWORD('#{user_pass}') WHERE User='#{user_name}';FLUSH PRIVILEGES;\""

    command = Mixlib::ShellOut.new(command_str)
    command.run_command
    if(command.stderr.length > 0)
      Chef::Log.error(command.stderr)
      raise StandardError, command.stderr
      false
    else
      Chef::Log.info("Password is updated now!")
      true
    end
  end

  def validate_parameters(action, exec_user_name, exec_user_pass, user_name, user_pass)
    action_symbol = action.class == Symbol ? action : action[0]
    if action_symbol == :change
      raise ArgumentError, "The user_name attribute is required in order to change its password" if user_name.nil? || user_name == ''
    end
  end

  def password_is_updated
    exe = exe_path
    action_symbol = new_resource.action.class == Symbol ? new_resource.action : new_resource.action[0]
    if action_symbol == :change_initial_root
      command_str = "#{exe_path} -u root --execute \"exit\""
    else
      command_str = "#{exe_path} -u #{@current_resource.user_name} -p#{@current_resource.user_pass} --execute \"exit\""
    end
    
    command = Mixlib::ShellOut.new command_str
    command.run_command
    if command.stderr.length > 0 && !command.stderr.include?('ERROR 1045')
      command.error!
    end
    case action_symbol
    when :change_initial_root
      command.stderr.include? 'ERROR 1045'
    when :change
      !command.stderr.include? 'ERROR 1045'
    else
      raise ArgumentError, "Action not implemented yet"
    end
  end

  

