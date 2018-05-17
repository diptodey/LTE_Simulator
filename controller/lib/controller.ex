defmodule Controller do
  use GenServer

  ## Client API

  @doc """

  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def add_event(pid) do

  end

  ## Server Callbacks

  @doc """

  """
  def init(:ok) do

    {:ok}
  end

end
