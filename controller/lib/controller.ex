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

  def log(pid) do
    GenServer.call(pid, {:log})
  end


  ## Server Callbacks

  @doc """

  """
  def init(:ok) do
    {:ok, pid_logger} = Logutils.start_link('./../controller_log_file.txt')
    {:ok, pid_tti} = Agent_tti.start_link()
    {:ok, pid_nw} = Nwsim.start_link()

    # As part of controller init we need to initialize users.
    # read from a txt file and parse to create users, ue_ids used as identifiers
    # current implementation we will assume 4 users with userid 1 to 4
    # Donot use userid 0, this is meant to be broadcast #
    {:ok, pid_user_1} = Users.start_link(1, :user_events_1)
    {:ok, pid_user_2} = Users.start_link(2, :user_events_2)
    {:ok, pid_user_3} = Users.start_link(3, :user_events_3)
    {:ok, pid_user_4} = Users.start_link(4, :user_events_4)
    {:ok, %{logger_pid: pid_logger,
            nw_pid: pid_nw,
            tti_pid: pid_tti,
            user_pid: [pid_user_1, pid_user_2, pid_user_3, pid_user_4]}}
  end

  def handle_call({:run_next_tti}, _from, state ) do
    time_params = Agent_tti.get_curr_tti(state[:tti_pid])
    # Heart of the controller:
    # First run all tx events both in network and Users
    # Second run all rx events

    # Run all User Tx events
    state[:user_pid] |> Enum.map(fn(x) -> x |> Users.run_tx_events(time_params) end)

    # Run all Nw Tx events
    Nwsim.run_tx_events(state[:nw_pid], time_params )

    #Generate Possible User Rx events
    state[:user_pid] |> Enum.map(fn(x) -> x |> Users.gen_rx_events(time_params) end)

    # Search Nw Tx database to find RX user Events
    ret = Nwsim.get_tx_events(state[:nw_pid], time_params)

    # Search User Tx datatbase to find RX Nw Events
    {:reply, state, state}
  end


  def handle_call({:log}, _from, state) do
    #Generate network logs
    Nwsim.log(state[:nw_pid])
    #Generate User Logs
    state[:user_pid] |> Enum.map(fn(x) -> Users.log(x) end)
    {:reply, state, state}
  end

  ## Helper Functions

  defp run_nw_tx(nwpid, time_params) do
    Nwsim.run_tx_events(nwpid, time_params )
  end

end
