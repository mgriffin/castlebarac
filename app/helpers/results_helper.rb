# frozen_string_literal: true

module ResultsHelper
  def net_time(seconds)
    h = seconds.to_i / 3600
    m = (seconds.to_i % 3600) / 60
    s = seconds.to_i % 60
    ms = seconds.to_s.match(%r((\.\d+)))&.captures&.first || ""

    if h == 0
      h = ""

      if m == 0
        m = ""
      else
        m = "#{m}:"
      end
    else
      h = "#{h}:"
      m = sprintf("%02d:", m)
    end

    s = sprintf("%02d", s) unless m == ""

    "#{h}#{m}#{s}#{ms[0..2]}"
  end
end
