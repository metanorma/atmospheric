# frozen_string_literal: true

module Atmospheris
  module Export
    module Iso25331975
      autoload :GroupOne, "atmospheris/export/iso_25331975/group_one"
      autoload :GroupTwo, "atmospheris/export/iso_25331975/group_two"
      autoload :GroupThree, "atmospheris/export/iso_25331975/group_three"
      autoload :GroupOneAttrs, "atmospheris/export/iso_25331975/group_one_attrs"
      autoload :GroupTwoAttrs, "atmospheris/export/iso_25331975/group_two_attrs"
      autoload :GroupThreeAttrs, "atmospheris/export/iso_25331975/group_three_attrs"

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
