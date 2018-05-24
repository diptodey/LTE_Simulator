defmodule Dl_sync_server do
  use GenServer
  use Export.Python

  @python_dir "./../python_lib"
  ## Client API

  @doc """

  """
  def start_link(state) do
    GenServer.start_link(__MODULE__,  state)
  end

  def sync_pss_add(pid, _msg, time_params) do
      GenServer.call(pid, {:sync_pss_add, time_params})
  end

  def sync_sss_add(pid, _msg, time_params) do
    GenServer.call(pid, {:sync_sss_add, time_params})
  end
  ## Server Callbacks

  @doc """

  """
  def init(state) do
    #:dets.open_file(:nw_events, [{:file, 'nw_events.txt'}, {:type, :duplicate_bag}])
    #:dets.insert(:nw_events, {0, 1, "Tx", :sync_pss_add})
    #:dets.insert(:nw_events, {0, 0, "Tx", :sync_sss_add})
    #:dets.close(:nw_events)
    Common_utils.add_event_db(0, 1, "Tx", :sync_pss_add, %{} )
    Common_utils.add_event_db(0, 0, "Tx", :sync_sss_add, %{} )
    {:ok, state}
  end

  def handle_call({:sync_pss_add, time_params}, _from, state) do
    %{system_frame_no: system_frame_no, sfn: sfn } = time_params
    %{
      bw: bw,
      cell_number: cell_number,
      cell_group_number: _,
    } = state

    {:ok, pid} = Python.start(python_path: Path.expand(@python_dir))
    Python.call(pid, "tdd_sync", "add_pss", [sfn, bw, 2, cell_number])
    Python.stop(pid)
    case sfn do
      1 -> Common_utils.add_event_db(system_frame_no, 6, "Tx", :sync_pss_add, %{} )
      6 -> Common_utils.add_event_db(system_frame_no + 1, 1, "Tx", :sync_pss_add, %{} )
    end
    {:reply, state, state}
  end


  def handle_call({:sync_sss_add, time_params}, _from, state) do
    %{system_frame_no: system_frame_no, sfn: sfn } = time_params
    %{
      bw: bw,
      cell_number: cell_number,
      cell_group_number: cell_group_number,
    } = state

    {:ok, pid} = Python.start(python_path: Path.expand(@python_dir))
    Python.call(pid, "tdd_sync", "add_sss", [sfn, bw, 13, cell_group_number, cell_number])
    Python.stop(pid)
    case sfn do
      0 -> Common_utils.add_event_db(system_frame_no, 5, "Tx", :sync_sss_add, %{} )
      5 -> Common_utils.add_event_db(system_frame_no + 1, 0, "Tx", :sync_sss_add, %{} )
    end
    {:reply, state, state}
  end

end
