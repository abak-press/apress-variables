module Apress
  module Variables
    class Engine < ::Rails::Engine
      config.paths.add 'app/docs', eager_load: false

      Apress::Documentation.add_load_path(config.root.join('app/docs'))
    end
  end
end
