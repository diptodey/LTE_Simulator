defmodule Users do
  @moduledoc """
  Documentation for Users.
  """

  use GenServer

  ## Client API

  @doc """

  """
  def start_link(user_id) do
    GenServer.start_link(__MODULE__, [user_id])
  end


  def run_rx_events(pid, rx_params, time_params) do
    GenServer.call(pid, {Enum.at(rx_params, 0), Enum.at(rx_params, 1), time_params })
  end

## Server Callbacks
  def init(user_id) do
    {:ok, user_agent_pid} = Agent_user_params.start_link()
    {:ok,
    %{user_id: user_id, user_agent_pid: user_agent_pid},
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
  ## Server API



end
