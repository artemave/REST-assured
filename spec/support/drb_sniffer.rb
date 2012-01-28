require 'drb'

module DrbSniffer
  def drb?
    !!(DRb.current_server rescue false)
  end
end
