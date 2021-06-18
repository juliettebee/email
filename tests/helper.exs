defmodule Helper do
  def connect_and_send(command) do
    {:ok, socket} = :gen_tcp.connect('localhost', 2525, [:binary, active: false])
    {:ok, _} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, command)   
    {:ok, message} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, "QUIT")
    message
  end
end
