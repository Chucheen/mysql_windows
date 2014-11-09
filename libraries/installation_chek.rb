module InstallationCheck 
  def InstallationCheck.installed?(program_name, letter_case=:normal)
     require 'win32/registry'
    keynames = ['Software\Microsoft\Windows\CurrentVersion\Uninstall','Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall']

    # KEY_ALL_ACCESS enables you to write and deleted.
    # the default access is KEY_READ if you specify nothing
    access = Win32::Registry::KEY_ALL_ACCESS|0x100
    program_exists = false
    keynames.each do |keyname|
      Win32::Registry::HKEY_LOCAL_MACHINE.open(keyname, access) do |reg_keys|
        reg_keys.each_key do |key, value|

          keyname_install = "#{keyname}\\#{key}"
          Win32::Registry::HKEY_LOCAL_MACHINE.open(keyname_install, access) do |reg|
            begin
              display_name = reg['displayname', Win32::Registry::REG_SZ]
              case letter_case
              when :upper
                display_name.upcase!
              when :lower
                display_name.downcase!
              end
              program_exists = true and break if display_name.include? program_name
            rescue
              # Nothing to do here
            end
          end
        end
      end  
    end
    program_exists
  end
end