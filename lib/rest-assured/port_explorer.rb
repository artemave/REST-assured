require 'socket'

class PortExplorer
  def free_tcp_port
    server = TCPServer.new('127.0.0.1', 0)
    free_port = server.addr[1]
    server.close
    free_port
  end
end
