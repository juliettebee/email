defmodule Helper do
  def connect_and_send(command) do
    {:ok, socket} = :gen_tcp.connect('localhost', 2525, [:binary, active: false])
    {:ok, _} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, command)   
    {:ok, message} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, "QUIT")
    message
  end

  def connect_and_send_data(data) do
    {:ok, socket} = :gen_tcp.connect('localhost', 2525, [:binary, active: false])
    {:ok, _} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, "DATA")   
    {:ok, _} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, data)

    {:ok, response} = :gen_tcp.recv(socket, 0)
    IO.puts response 

    :gen_tcp.send(socket, "QUIT")
  end

  def get_contents_of_newest_email do
    file = File.cwd! <> "/tests/emails/*" |>
      Path.wildcard |>
      hd 

    {:ok, contents} = File.read file

    File.rm file

    contents
  end

  def server_is_up do
    {:ok, socket} = :gen_tcp.connect('localhost', 2525, [:binary, active: false])
    {:ok, message} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, "quit")

    message
  end
end
