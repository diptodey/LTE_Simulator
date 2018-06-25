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

  def run_rx_events(pid, rx_params, time_params) do
    GenServer.call(pid, {Enum.at(rx_params, 0), Enum.at(rx_params, 1), time_params })
  end

  def log(pid) do
    GenServer.call(pid,{:log})
  end

## Server Callbacks
  def init([user_id, tablename]) do
    {:ok, pid_logger} = Logutils.start_link("user_#{user_id}_log_file.txt")
    {:ok, user_agent_pid} = Agent_user_params.start_link()
    filename = './../userid_#{user_id}_events.txt'
    Common_utils.delete_file_if_exists?(filename)
    :dets.open_file(tablename, [{:file, filename}, {:type, :duplicate_bag}])
    :dets.close(tablename)

    {:ok,
      %{
        tablename: tablename,
        user_id: user_id,
        pid_logger: pid_logger,
        user_agent_pid: user_agent_pid,
        }
    }
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


  def handle_call({:sync_pss, msg, _time_params}, _from, state ) do
    %{cell_number: cell_number} = msg
    user_agent_pid = state[:user_agent_pid]
    Agent_user_params.update_param( user_agent_pid, :cell_number, cell_number)
    {:reply, state, state}
  end


  def handle_call({:sync_sss, msg, _time_params}, _from, state ) do
    %{cell_group_number: cell_group_number, cell_number: cell_number} = msg
    user_agent_pid = state[:user_agent_pid]
    Agent_user_params.update_param( user_agent_pid, :cell_group_number, cell_group_number)
    Agent_user_params.update_param( user_agent_pid, :cell_number, cell_number)
    {:reply, state, state}
  end


  def handle_call({:pcfich, _msg, _time_params}, _from, state) do
    {:reply, state, state}
  end

  def handle_call({:log}, _from, state) do
    filename = 'userid_#{state[:user_id]}_events.txt'
    :dets.open_file(state[:tablename], [{:file, filename}, {:type, :duplicate_bag}])
    ret = :dets.match(state[:tablename], {:"$1", :"$2", :"$3", :"$4", :"$5", :"$6"})
    ret |> Enum.map( fn(x) -> state[:logger_pid] |> Logutils.write_line( inspect(x)) end )
    {:reply, state, state}
  end

  ## Server API



end
