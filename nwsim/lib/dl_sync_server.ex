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

  def sync_pss_add(pid, time_params) do
      GenServer.call(pid, {:sync_pss_add, time_params})
  end

  def sync_sss_add(pid, time_params) do
    GenServer.call(pid, {:sync_sss_add, time_params})
  end
  ## Server Callbacks

  @doc """

  """
  def init(state) do
    :dets.open_file(:nw_events, [{:file, 'nw_events.txt'}, {:type, :duplicate_bag}])
    :dets.insert(:nw_events, {0, 1, "Tx", :sync_pss_add})
    :dets.insert(:nw_events, {0, 0, "Tx", :sync_sss_add})
    :dets.close(:nw_events)
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
    IO.puts("Adding next pss")
    IO.inspect(sfn)  
    :dets.open_file(:nw_events, [{:file, 'nw_events.txt'}, {:type, :duplicate_bag}])
    case sfn do
      1 -> :dets.insert(:nw_events, {system_frame_no, 6, "Tx", :sync_pss_add})
      6 -> :dets.insert(:nw_events, {system_frame_no + 1, 1, "Tx", :sync_pss_add})
    end
    :dets.close(:nw_events)
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
    IO.inspect(sfn)
    IO.inspect(bw)
    IO.inspect(cell_group_number)
    IO.inspect(cell_number)
    Python.call(pid, "tdd_sync", "add_sss", [sfn, bw, 13, cell_group_number, cell_number])
    Python.stop(pid)

    :dets.open_file(:nw_events, [{:file, 'nw_events.txt'}, {:type, :duplicate_bag}])
    case sfn do
      0 -> :dets.insert(:nw_events, {system_frame_no, 5, "Tx", :sync_sss_add})
      5 -> :dets.insert(:nw_events, {system_frame_no + 1, 0, "Tx", :sync_sss_add})
    end
    :dets.close(:nw_events)
    {:reply, state, state}
  end

end
