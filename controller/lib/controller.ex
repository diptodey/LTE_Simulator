defmodule Controller do
  use GenServer

  ## Client API

  @doc """

  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end


  def run_next_tti(pid) do
      GenServer.call(pid, {:run_next_tti})
  end


  ## Server Callbacks

  @doc """

  """
  def init(:ok) do
    {:ok, pid_tti} = Agent_tti.start_link()
    {:ok, pid_nw} = Nwsim.start_link()

    {:ok, %{nw_pid: pid_nw, tti_pid: pid_tti}}
  end

  def handle_call({:run_next_tti}, _from, state ) do
    time_params = Agent_tti.get_curr_tti(state[:tti_pid])
    run_nw_tx(state[:nw_pid],  time_params)
    #run_user_tx(state[:nw_pid], time_params)
    Agent_tti.incr_tti(state[:tti_pid])
    {:reply, state, state}
  end

  ## Helper Functions

  defp run_nw_tx(nwpid, time_params) do
    Nwsim.run_tx_events(nwpid, time_params )
  end


end
