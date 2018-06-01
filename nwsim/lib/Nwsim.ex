defmodule Nwsim do
  use GenServer
  use Export.Python

  @python_dir "./../python_lib/sql/"
  ## Client API

  @doc """

  """
  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  def show_dbase() do
    :dets.open_file(:nw_events, [{:file, './../nw_events.txt'}, {:type, :duplicate_bag}])
    ret = :dets.match(:nw_events, {:"$1", :"$2", :"$3", :"$4", :"$5", :"$6"})
    IO.inspect(ret)
  end

  def run_tx_events(pid, time_params) do
    # extract all tx events matching the frame and sfn number
    %{system_frame_no: system_frame_no, sfn: sfn } = time_params
    :dets.open_file(:nw_events, [{:file, './../nw_events.txt'}, {:type, :duplicate_bag}])
    ret = :dets.match(:nw_events, {system_frame_no, sfn, :"$3", :"$4", :"$5", :"$6"})
    ret |> Enum.map( fn(x) -> GenServer.call(pid, {Enum.at(x, 2), Enum.at(x, 3), time_params })  end)
  end


  def mib_get_state(pid) do
    GenServer.call(pid, {:mib_get_state})
  end
  ## Server Callbacks

  @doc """

  """
  def init(:ok) do
    # Remove old database and create new database
    Common_utils.delete_file_if_exists?("./../nw_events.txt")
    :dets.open_file(:nw_events, [{:file, './../nw_events.txt'}, {:type, :duplicate_bag}])
    :dets.close(:nw_events)
    {:ok, nw_params} = Agent_nw_params.start_link()

    {:ok, python_pid} = Python.start(python_path: Path.expand(@python_dir))
    Python.call(python_pid, "sql", "init_db",
               [  Agent_nw_params.get_param(nw_params, :total_no_carriers) * 12])
    Python.stop(python_pid)

    ### Start the MIB Server
    x = %{}
    x = x |> Map.put(:bw,                   Agent_nw_params.get_param(nw_params,  :bw))
    x = x |> Map.put(:phich_mode,           Agent_nw_params.get_param(nw_params, :phich_mode))
    x = x |> Map.put(:phich_ng,             Agent_nw_params.get_param(nw_params, :phich_ng))
    x = x |> Map.put(:number_enodeb_tx_ant, Agent_nw_params.get_param(nw_params, :number_enodeb_tx_ant))
    {:ok, dl_mib_pid} = Dl_mib_server.start_link(x)

    ### Start the Sync Server
    x = %{}
    x = x |> Map.put(:bw,                 Agent_nw_params.get_param(nw_params, :bw))
    x = x |> Map.put(:cell_number,        Agent_nw_params.get_param(nw_params, :cell_number))
    x = x |> Map.put(:cell_group_number,  Agent_nw_params.get_param(nw_params, :cell_group_number))
    {:ok, dl_sync_pid} = Dl_sync_server.start_link(x)

    ### Start the PCFICH Server
    x = %{}
    x = x |> Map.put(:cfi,                Agent_nw_params.get_param(nw_params, :cfi))
    x = x |> Map.put(:config,             Agent_nw_params.get_param(nw_params, :config))
    x = x |> Map.put(:cell_number,        Agent_nw_params.get_param(nw_params, :cell_number))
    x = x |> Map.put(:cell_group_number,  Agent_nw_params.get_param(nw_params, :cell_group_number))
    {:ok, dl_pcfich_pid} = Dl_pcfich_server.start_link(x)

    {:ok, %{nw_params: nw_params,
            dl_mib_pid: dl_mib_pid,
            dl_sync_pid: dl_sync_pid,
            dl_pcfich_pid: dl_pcfich_pid,
            }
    }
  end


  @doc """
    Add Tx Events for MIB, each frame first subframe
  """
  def handle_call({:mib, msg, time_params}, _from, state ) do
    dl_mib_pid = state |> Map.get(:dl_mib_pid)
    Dl_mib_server.mib_add(dl_mib_pid, msg, time_params)
    {:reply, state, state}
  end

  @doc """
    Add Tx Events for MIB recalc, every 40 msecs
  """
  def handle_call({:mib_recalc_40ms, _msg, time_params}, _from, state ) do
    x = %{}
    nw_params = state |> Map.get(:nw_params)
    x = x |> Map.put(:bw,                   Agent_nw_params.get_param(nw_params, :bw))
    x = x |> Map.put(:total_no_carriers,    Agent_nw_params.get_param(nw_params, :total_no_carriers))
    x = x |> Map.put(:phich_mode,           Agent_nw_params.get_param(nw_params, :phich_mode))
    x = x |> Map.put(:phich_ng,             Agent_nw_params.get_param(nw_params, :phich_ng))
    x = x |> Map.put(:number_enodeb_tx_ant, Agent_nw_params.get_param(nw_params, :number_enodeb_tx_ant))
    dl_mib_pid = state |> Map.get(:dl_mib_pid)
    Dl_mib_server.mib_recalc_40ms(dl_mib_pid, %{}, time_params, x)
    {:reply, state, state}
  end


  def handle_call({:sync_sss, msg, time_params}, _from, state ) do
    dl_sync_pid = state |> Map.get(:dl_sync_pid)
    Dl_sync_server.sync_sss_add(dl_sync_pid, msg, time_params)
    {:reply, state, state}
  end


  def handle_call({:sync_pss, msg, time_params}, _from, state ) do
    dl_sync_pid = state |> Map.get(:dl_sync_pid)
    Dl_sync_server.sync_pss_add(dl_sync_pid, msg, time_params)
    {:reply, state, state}
  end

  def handle_call({:mib_get_state}, _from, state) do
    dl_mib_pid = state |> Map.get(:dl_mib_pid)
    k = Dl_mib_server.mib_get_state(dl_mib_pid)
    {:reply, k, state}
  end

  def handle_call({:pcfich, msg, time_params}, _from, state) do
    dl_pcfich_pid = state |> Map.get(:dl_pcfich_pid)
    Dl_pcfich_server.pcfich_add(dl_pcfich_pid, msg, time_params)
    {:reply, state, state}
  end
  ## Server API



end
