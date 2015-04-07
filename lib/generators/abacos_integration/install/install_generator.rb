module AbacosIntegration
	module Generators

		class InstallGenerator < Rails::Generators::Base
			source_root File.expand_path('../templates', __FILE__)

			def generate_install
				directory = File.expand_path('../templates', __FILE__)

				template "config/initializers/abacos_integration.rb", "config/initializers/abacos_integration.rb"
			end

		end

	end
end