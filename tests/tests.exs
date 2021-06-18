Code.require_file "tests/helper.exs"
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
    message = Helper.connect_and_send "BAD COMMAND: BAD"
    assert message == "500 I don't know that\n"
  end

  test "HELO" do
    message = Helper.connect_and_send "HELO"
    assert message == "250 Hello\n"
  end

  test "MAIL FROM" do
    message = Helper.connect_and_send "MAIL FROM: <test@test.test>"
    assert message == "250 Ok\n"
  end

  test "RCPT TO" do
    message = Helper.connect_and_send "RCPT TO: <tester@test.test>"
    assert message == "250 Ok\n"
  end
end
