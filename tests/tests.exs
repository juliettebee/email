ExUnit.start

defmodule ConnectionTests do
    use ExUnit.Case, async: true

    test "Server is up" do
      {:ok, socket} = :gen_tcp.connect('localhost', 2525, [:binary, active: false])
      {:ok, message} = :gen_tcp.recv(socket, 0)
      assert message == "220 ESMTP Juliette's SMTP Server \n"
    end
end
