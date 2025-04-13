# frozen_string_literal: true

module Atmospheric
  module Export
    module Iso25331975
      class << self
        def table_5
          GroupOne.new.set_attrs
        end

        def table_6
          GroupTwo.new.set_attrs
        end

        def table_7
          GroupThree.new.set_attrs
        end
      end
    end
  end
end

require_relative "iso_25331975/group_one"
require_relative "iso_25331975/group_two"
require_relative "iso_25331975/group_three"
