defmodule Ue_Dl_sync_server do
  @moduledoc """
  Documentation for Dl_sync_server.
  """

  use GenServer

  ## Client API

  @doc """

  """
  def start_link(user_id, tablename, agent_userparams) do
    GenServer.start_link(__MODULE__, [user_id, tablename, agent_userparams])
  end

  def generate_rx_events(pid, time_params) do
    GenServer.call(pid, {:gen_rx_events, time_params})
  end

  def sync_pss_add(pid, _msg, time_params) do
      GenServer.call(pid, {:sync_pss, time_params})
  end

  def sync_sss_add(pid, _msg, time_params) do
    GenServer.call(pid, {:sync_sss, time_params})
  end
  

  ## Server Callbacks

  def init([user_id, tablename, agent_userparams]) do

    {:ok,
      %{
        user_id: user_id,
        tablename: tablename,
        agent_userparams: agent_userparams,
        # State machine for Dl_sync_server
        # :init -> no sync signal acquired
        # :pss  -> pss acquired
        # :sss  -> sss acquired
        fsm_state: :init,
        }
      }
  end

  def handle_call({:gen_rx_events, time_params}, _from, state) do
    %{system_frame_no: system_frame_no, sfn: sfn } = time_params
    #table_name, user_id, system_frame_no, sfn, type, event_tag, params
    cond do
      state[:fsm_state] == :init ->
        # If the state is init pss needs to be monitored every sfn and hence this sfn
        User_utils.add_event_db(state[:tablename], state[:user_id], system_frame_no, sfn , :User_Rx, :sync_pss, %{})
      state[:fsm_state] == :pss  ->
        # pss has been found need to monitor for sss, sss is carried in slots 1 and 11
        case sfn do
          {0,5} -> User_utils.add_event_db(state[:tablename], state[:user_id], system_frame_no, sfn , :User_Rx, :sync_sss, %{})
        end
    end
    {:reply, state, state}
  end


  def handle_call({:sync_pss, msg, _time_params}, _from, state ) do
    %{bw: bw, cell_group_number: cell_group_number} = msg
    agent_userparams = state[:agent_userparams]
    Agent_user_params.update_param( agent_userparams, :bw, bw)
    Agent_user_params.update_param( agent_userparams, :cell_group_number, cell_group_number)
    {:reply, state, state}
  end


  def handle_call({:sync_sss, msg, _time_params}, _from, state ) do
    %{cell_number: cell_number} = msg
    agent_userparams = state[:agent_userparams]
    Agent_user_params.update_param( agent_userparams, :cell_number, cell_number)
    {:reply, state, state}
  end

  ## Helper Functions


end
