defmodule Dl_cell_specific_rs_server do
  use GenServer
  use Export.Python

  ## Client API

  @doc """

  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end


  ## Server Callbacks

  @doc """

  """
  def init(:ok) do
    {:ok, %{}}
  end

end
