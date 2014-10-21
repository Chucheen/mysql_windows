actions :change, :change_initial_root

default_action :change
attribute :execution_user_name, kind_of: String, default: 'root'
attribute :execution_user_pass, kind_of: String, default: ''
attribute :user_name, kind_of: String
attribute :user_pass, kind_of: String, required: true, callbacks: {
	"Should have a length of 6 characters at least" => lambda { |password|
		password.length >= 6
	}
}

# In case bin/mysql is not already in path, installation_path needs to be defined
attribute :installation_path, kind_of: String

attr_accessor :updated_already