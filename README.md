mysql_windows LWRP
=================
Provides chef resources for MySQL

Requirements
------------

- Requires windows cookbook

- MySQL 5.0 or later


### Platforms
- windows



Attributes
----------
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>[:mysql_windows][:lwrp][:remove_completely]</tt></td>
    <td>Boolean</td>
    <td>Used only for uninstall action from service resource. It defines if data folder is going to be erased too</td>
    <td><tt>true</tt></td>
  </tr>
</table>

## Resource/Provider

## mysql\_windows\_service

Execute install and uninstallation of MySQL. Also, if the attribute root_password is defined, then the root's password is set at the end of the installation

### Actions

- **install (default)**
- **uninstall**

### Attribute Parameters
- **installation_name**: Name of the installation. It can be defined as the resource name. (Mandatory)
- **msi\_url\_path**: absoute url where the installer is placed. This value may be specified as HTTP `(http://)`, FTP `(ftp://)`, or local `(file://)` source file locations. (Mandatory)
- **msi\_url\_file**: filename of the msi installer. Is used along with `msi_url_path` attribute to get the full download link. (Mandatory)
- **installation_path**: used to define where is or is going to be installed MySQL. 
- **root_password**: defines the password that is going to be set when installing MySQL. If the password is already set because of an old installation, it won't be set again and a warning will be shown. This only works for installation action. More than six letters are required.

### Examples

Run installation, using a local msi installer (c:\mysql-essential-5.0.51a-winx64.msi) and set password for root:

```ruby
mysql_windows_service "MySQL Server 5.0" do
  msi_url_path        'file://c:'
  msi_url_file        'mysql-essential-5.0.51a-winx64.msi'
  root_password		  'devtest'
end
```

Run uninstallation, setting remove_completely to true in order to fully delete MySQL.

```ruby
node.set[:mysql_windows][:lwrp][:remove_completely] = true

mysql_windows_service "MySQL Server 5.0" do
  msi_url_path        'http://devfactory-user-data.s3.amazonaws.com/packages/MySQL/windows'
  msi_url_file        'mysql-essential-5.0.51a-winx64.msi'
  action              :uninstall
end

```

## mysql\_windows\_password

Execute password set, either setting root password for a fresh installation or any other existent user.

### Actions

- **change (default)**: Change the password for a specific user. 
- **change_initial\_root**: Change the root password for a fresh installation.

### Attribute Parameters

- **execution\_user\_name**: user that has enough permissions to execute the password change command in MySQL.
- **execution\_user\_pass**: password for the _execution\_user\_name_ typed
- **user_name**: UserName for which the password is going to be changed
- **user_pass**: Password for the _user\_name_ typed
- **installation\_path**: Installation path where MySQL is installed. You can either include _/bin_ at the end of the _installation\_path_ or leave it like that. If MYSQL_PATH/bin is already added to PATH env variable, this could be omitted.

### Examples


Changing password for user `new_user` using `root` as the user that executes the password.

```ruby
mysql_windows_password "Changing passowrd" do
	installation_path 'C:\Program Files\MySQL\MySQL Server 5.0\bin'
	execution_user_name 'root'	
	execution_user_pass 'devtest'
	user_name 'new_user'
	user_pass 'devtest'
end 
```

Changing password for user `other_user` using `new_user` as the user that executes the password.

```ruby
mysql_windows_password "Changing passowrd" do
	execution_user_name 'new_user'	
	execution_user_pass 'devtest'
	user_name 'another_user'
	user_pass 'mypass'
end 
```

Changing initial root password providing the installation_path

```ruby
mysql_windows_password "Changing root password for the first time" do
	installation_path 'C:\Program Files\MySQL\MySQL Server 5.0'
	user_pass 'devtest'
	action :change_initial_root
end
```

Changing initial root password whithouth providing installation_path as MYSQL_PATH/bin is already included in PATH

```ruby
mysql_windows_password "Changing root password for the first time" do
	user_pass 'devtest'
	action :change_initial_root
end
```

Contributing
------------
1. Fork the repository on Github
2. Create a named feature branch (like `add_new_resource_provider`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Author: JGutiérrezC (<jegut87@gmail.com>)


Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

<http://www.apache.org/licenses/LICENSE-2.0>

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.