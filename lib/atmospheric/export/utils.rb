module Atmospheric
  module Export
    module Utils
      def values_in_m_ft(value, unit: :meters)
        case unit
        when :meters
          [value.to_f, m_to_ft(value)]
        when :feet
          [ft_to_m(value), value.to_f]
        end
      end

      def round_to_sig_figs(num, num_sig_figs)
        num.round(num_sig_figs - Math.log10(num).ceil).to_f
      end

      def m_to_ft(meters)
        meters / 0.3048
      end

      def ft_to_m(feet)
        feet * 0.3048
      end
    end
  end
end
