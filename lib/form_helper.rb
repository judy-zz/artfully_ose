module ActionView
  module Helpers
    module FormHelper
      def date_field(object_name, method, options = {})
        Tags::DateField.new(object_name, method, self, options).render
      end
    end
  end
end

module ActionView
  module Helpers
    module Tags
      autoload :DateField

    end
  end
end
