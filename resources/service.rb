actions :install, :uninstall
 
default_action :install

# Required Attributes
attribute :installation_name, kind_of: String, name_attribute: true


# Place where the msi installer file is going to be either 
# downloaded or where it is already placed 				 
# if both groups ((msi_url_path and msi_url_file) && (:msi_local_path and :msi_local_file))
# are defined in the resource, locals takes precedence and url's are ignored

# Define both url attributes if it's going to be installed via URL
attribute :msi_url_path, kind_of: String, required: true
attribute :msi_url_file, kind_of: String, required: true

# Define the path where MySQL is going to be installed
attribute :installation_path, kind_of: String

# Root User 
attribute :root_password, kind_of: String,  callbacks: {
	"Should have a length of 6 characters at least" => lambda { |password|
		password.length >= 6
	}
}

attribute :remove_completely, kind_of: [ TrueClass, FalseClass ], default: false