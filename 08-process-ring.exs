defmodule Pinger do
  def ping(echo, limit) do
    receive do
      {[next | rest], msg, count} when count <= limit ->
        IO.puts "Received: #{inspect msg} (count #{count})"

        :timer.sleep(10)
        send next, {rest ++ [next], echo, count + 1}
        ping(echo, limit)

      # over our limit of messages, send :ok around the ring
      {[next | rest], _, _} ->
        send next, {rest, :ok}

      #someone told us to stop, so pass along the message
      {[next | rest], :ok} ->
        send next, {rest, :ok}
    end
  end
end

defmodule Spawner do
  def spawn do
    limit = 5
    {foo, _foo_monitor} = spawn_monitor(Pinger, :ping, ["foo", limit])
    {bar, _bar_monitor} = spawn_monitor(Pinger, :ping, ["bar", limit])
    {baz, _baz_monitor} = spawn_monitor(Pinger, :ping, ["baz", limit])

    send foo, {[bar, baz, foo], "start", 0}
    wait [foo, bar, baz]
  end

  def wait(pids) do
    IO.puts "Waiting for pids #{inspect pids}"
    receive do
      {:DOWN, _, _, pid, _} ->
        IO.puts "#{inspect pid} quit"

        pids = List.delete(pids, pid)
        unless Enum.empty?(pids) do
          wait(pids)
        end
    end
  end
end

Spawner.spawn()

