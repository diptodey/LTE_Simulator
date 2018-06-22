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
    {:ok, pid_logger} = Logutils.start_link()
    {:ok, pid_tti} = Agent_tti.start_link()
    {:ok, pid_nw} = Nwsim.start_link()



    # As part of controller init we need to initialize users.
    # read from a txt file and parse to create users, ue_ids used as identifiers
    # current implementation we will assume 4 users with userid 1 to 4
    # Donot use userid 0, this is meant to be broadcast #
    {:ok, pid_user_1} = Users.start_link(1)
    {:ok, pid_user_2} = Users.start_link(2)
    {:ok, pid_user_3} = Users.start_link(3)
    {:ok, pid_user_4} = Users.start_link(4)
    {:ok, %{logger_pid: pid_logger,
            nw_pid: pid_nw,
            tti_pid: pid_tti,
            user_pid: [pid_user_1, pid_user_2, pid_user_3, pid_user_4]}}
  end

  def handle_call({:run_next_tti}, _from, state ) do
    time_params = Agent_tti.get_curr_tti(state[:tti_pid])
    run_nw_tx(state[:nw_pid],  time_params)
    state[:user_pid] |> Enum.map(fn(x) -> run_user_broadcast_rx(time_params, x) end)


    #Log the tti results
    #Agent_tti.incr_tti(state[:tti_pid])
    {:reply, state, state}
  end


  def handle_call({:log}, _from, state) do
    #Log the tti results
    :dets.open_file(:nw_events, [{:file, './../nw_events.txt'}, {:type, :duplicate_bag}])
    ret = :dets.match(:nw_events, {:"$1", :"$2", :"$3", :"$4", :"$5", :"$6"})
    ret |> Enum.map( fn(x) -> state[:logger_pid] |> Logutils.write_line( inspect(x)) end )
    {:reply, state, state}
  end

  ## Helper Functions

  defp run_nw_tx(nwpid, time_params) do
    Nwsim.run_tx_events(nwpid, time_params )
  end

  defp run_user_broadcast_rx(time_params, pid_user) do
    %{system_frame_no: system_frame_no, sfn: sfn } = time_params
    :dets.open_file(:nw_events, [{:file, './../nw_events.txt'}, {:type, :duplicate_bag}])
    ret = :dets.match(:nw_events, {system_frame_no, sfn, :Nw_Tx, 0, :"$5", :"$6"})
    ret |> Enum.map( fn(x) -> Users.run_rx_events(pid_user,  x, time_params)  end)
  end


end
