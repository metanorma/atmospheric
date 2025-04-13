# frozen_string_literal: true

require_relative "./iso_25331975"

module Atmospheric
  module Export
    module Iso25331997
      module GroupBaseMeters
        def steps
          (-5000..2000).step(50)
        end
      end

      class GroupOne < Iso25331975::GroupOne
        include Iso25331997::GroupBaseMeters
      end

      class GroupTwo < Iso25331975::GroupTwo
        include Iso25331997::GroupBaseMeters
      end

      class GroupThree < Iso25331975::GroupThree
        include Iso25331997::GroupBaseMeters
      end

      module GroupBaseFeet
        def steps
          (
            (-16_500..-13_750).step(250) +
            (-14_000..104_800).step(200) +
            (105_000..262_500).step(500)
          )
        end

        def steps_unit
          :feet
        end
      end

      class GroupFour < Iso25331975::GroupOne
        include Iso25331997::GroupBaseFeet
        def set_attrs(klass: Iso25331975::GroupOneAttrs, unit: steps_unit)
          super
        end
      end

      class GroupFive < Iso25331975::GroupTwo
        include Iso25331997::GroupBaseFeet
        def set_attrs(klass: Iso25331975::GroupTwoAttrs, unit: steps_unit)
          super
        end
      end

      class GroupSix < Iso25331975::GroupThree
        include Iso25331997::GroupBaseFeet
        def set_attrs(klass: Iso25331975::GroupThreeAttrs, unit: steps_unit)
          super
        end
      end

      class << self
        def table_1
          GroupOne.new.set_attrs
        end

        def table_2
          GroupTwo.new.set_attrs
        end

        def table_3
          GroupThree.new.set_attrs
        end

        def table_4
          GroupFour.new.set_attrs
        end

        def table_5
          GroupFive.new.set_attrs
        end

        def table_6
          GroupSix.new.set_attrs
        end
      end
    end
  end
end
