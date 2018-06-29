defmodule Users do
  @moduledoc """
  Documentation for Users.
  """

  use GenServer

  ## Client API

  @doc """

  """
  def start_link(user_id, tablename) do
    GenServer.start_link(__MODULE__, [user_id, tablename])
  end

  def gen_rx_events(pid, time_params) do
    GenServer.call(pid, {:gen_rx_events , time_params} )
  end

  def log(pid) do
    GenServer.call(pid, {:log})
  end

## Server Callbacks
  def init([user_id, tablename]) do
    {:ok, pid_logger} = Logutils.start_link('./../user_#{user_id}_log_file.txt')
    {:ok, user_agent_pid} = Agent_user_params.start_link()

    filename = './../userid_#{user_id}_events.txt'
    User_utils.delete_file_if_exists?(filename)
    :dets.open_file(tablename, [{:file, filename}, {:type, :duplicate_bag}])
    :dets.close(tablename)

    #### Start the Sync Server ###
    {:ok, dl_sync_pid} = Ue_Dl_sync_server.start_link(user_id, pid_logger, user_agent_pid)

    {:ok,
      %{
        tablename: tablename,           #dets table name to store the  database
        user_id: user_id,               # unique user id for each user
        pid_logger: pid_logger,         # logging server pid one for each user
        user_agent_pid: user_agent_pid, # agent database for user params
        dl_sync_pid: dl_sync_pid
        }
    }
  end


  def handle_call({:gen_rx_events, time_params}, _from, state) do
    Ue_Dl_sync_server.generate_rx_events(state[:dl_sync_pid], time_params)
    {:reply, state, state}
  end


  def handle_call({:mib, msg, _time_params}, _from, state ) do
    %{bw: bw, number_enodeb_tx_ant: number_enodeb_tx_ant, phich_mode: phich_mode, phich_ng: phich_ng } = msg
    user_agent_pid = state[:user_agent_pid]
    Agent_user_params.update_param( user_agent_pid, :bw, bw)
    Agent_user_params.update_param( user_agent_pid, :number_enodeb_tx_ant, number_enodeb_tx_ant)
    Agent_user_params.update_param( user_agent_pid, :phich_mode, phich_mode)
    Agent_user_params.update_param( user_agent_pid, :phich_ng, phich_ng)
    {:reply, state, state}
  end


  def handle_call({:pcfich, _msg, _time_params}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:log}, _from, state) do
    filename = './../userid_#{state[:user_id]}_events.txt'
    :dets.open_file(state[:tablename], [{:file, filename}, {:type, :duplicate_bag}])
    ret = :dets.match(state[:tablename], {:"$1", :"$2", :"$3", :"$4", :"$5", :"$6"})
    ret |> Enum.map( fn(x) -> state[:pid_logger] |> Logutils.write_line( inspect(x)) end )
    {:reply, state, state}
  end

  ## Server API



end
