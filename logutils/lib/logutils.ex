defmodule Logutils do
  @moduledoc """
  Documentation for Logutils.
  """

  use GenServer

  ## Client API

  @doc """

  """
  def start_link(filename) do
    GenServer.start_link(__MODULE__, filename)
  end

  def write_line(pid, line) do
    GenServer.call(pid, line)
  end

  ## Server Callbacks

  @doc """

  """
  def init(filename) do
    #Common_utils.delete_file_if_exists?("./log.txt")
    file = File.open!(filename, [:utf8, :write])
    IO.inspect(file)
    {:ok, %{file: file}}
  end

  def handle_call(line, _from, state) do
    IO.inspect(line)
    IO.puts(state[:file], line)
    {:reply, state, state}
  end

end
