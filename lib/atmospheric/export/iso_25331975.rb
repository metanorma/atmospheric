# frozen_string_literal: true

module Atmospheric
  module Export
    module Iso25331975
      autoload :GroupOne, "atmospheric/export/iso_25331975/group_one"
      autoload :GroupTwo, "atmospheric/export/iso_25331975/group_two"
      autoload :GroupThree, "atmospheric/export/iso_25331975/group_three"
      autoload :GroupOneAttrs, "atmospheric/export/iso_25331975/group_one_attrs"
      autoload :GroupTwoAttrs, "atmospheric/export/iso_25331975/group_two_attrs"
      autoload :GroupThreeAttrs, "atmospheric/export/iso_25331975/group_three_attrs"

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
