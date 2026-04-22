# frozen_string_literal: true

# The purpose of this class is really for XML grouping.
# It is not a table in the same sense as the other tables.
# It is a collection of attributes grouped by altitude type.
# This class is used to group the attributes by altitude type
# and to serialize them to XML.

# The class is used in the CombinedAltitudeAttrsGroup class
# and is not intended to be used directly.
module Atmospheric
  module Export
    module Iso25332025
      class AltitudeAttrsGroup < Lutaml::Model::Serializable
        attribute :rows, AltitudeAttrs, collection: true

        xml do
          element "attributes-group"
          namespace Atmospheric::Iso2533Namespace
          map_element "atmospheric-attributes", to: :rows
        end
      end
    end
  end
end
