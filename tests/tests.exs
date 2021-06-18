ExUnit.start

defmodule ConnectionTests do
    use ExUnit.Case, async: true

    test "Server is up" do
      {:ok, socket} = :gen_tcp.connect('localhost', 2525, [:binary, active: false])
      {:ok, message} = :gen_tcp.recv(socket, 0)
      :gen_tcp.send(socket, "QUIT")
      assert message == "220 ESMTP Juliette's SMTP Server \n"
    end
end

defmodule CommandTests do
  use ExUnit.Case, async: true

  test "Invalid command" do
    {:ok, socket} = :gen_tcp.connect('localhost', 2525, [:binary, active: false])
    {:ok, _} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, "BAD COMMAND: BAD")
    {:ok, message} = :gen_tcp.recv(socket, 0)   
    :gen_tcp.send(socket, "QUIT") 
    assert message == "500 I don't know that\n"
  end

  test "HELO" do
    {:ok, socket} = :gen_tcp.connect('localhost', 2525, [:binary, active: false])
    {:ok, _} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, "HELO")
    {:ok, message} = :gen_tcp.recv(socket, 0)
    :gen_tcp.send(socket, "QUIT")
    assert message == "250 Hello\n"
  end
end
