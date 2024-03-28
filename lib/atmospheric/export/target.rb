require "measured"
require "yaml"

module Atmospheric
  module Export

    module Target
      def round_to_sig_figs(num, num_sig_figs)
        num.round(num_sig_figs - Math.log10(num).ceil).to_f
      end

      def m_to_ft(meters)
        Measured::Length.new(meters, "m").convert_to("ft").value.to_f
      end

      def ft_to_m(feet)
        Measured::Length.new(feet, "ft").convert_to("m").value.to_f
      end

      def to_yaml
        to_h
          .to_yaml(indentation: 4)
          .gsub("\n-   ", "\n\n  - ")
          .gsub(/^(.*):\n/, "\n\\1:") # Make fancy
      end

      def to_file(hash = to_yaml)
        File.write(filename, hash)
      end
    end
  end
end
