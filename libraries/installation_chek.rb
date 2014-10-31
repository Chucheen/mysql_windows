module InstallationCheck 

  require 'win32/registry'
  keynames = ['Software\Microsoft\Windows\CurrentVersion\Uninstall','Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall']

  # KEY_ALL_ACCESS enables you to write and deleted.
  # the default access is KEY_READ if you specify nothing
  #access = Win32::Registry::KEY_ALL_ACCESS|0x100
  access = Win32::Registry::KEY_ALL_ACCESS|0x100

  keynames.each do |keyname|
    Win32::Registry::HKEY_LOCAL_MACHINE.open(keyname, access) do |reg_keys|
      reg_keys.each_key do |key, value|
        keyname_install = "#{keyname}\\#{key}"
        puts keyname_install
        #Win32::Registry::HKEY_LOCAL_MACHINE.open(keyname_install,access) do |reg|
        #  puts reg['displayname', Win32::Registry::REG_SZ]
        #end
        
        #Win32::Registry::HKEY_LOCAL_MACHINE.open("keyname")
      end
      # each is the same as each_value, because #each_key actually means 
      # "each child folder" so #each doesn't list any child folders...
      # use #keys for that...
      # value = reg['displayname', Win32::Registry::REG_SZ]
      # reg.read('displayname')
      # reg.each_key{|name, value| puts name, value}
    end  
  end
end