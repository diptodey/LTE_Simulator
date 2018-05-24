defmodule Dl_mib_server do
  use GenServer
  use Export.Python

  @python_dir "./../python_lib"
  ## Client API
  @doc """
  """
  def start_link(state) do
    GenServer.start_link(__MODULE__,  state)
  end

  def mib_recalc_40ms(pid, _msg, time_params, x) do
    GenServer.call(pid, {:mib_recalc_40ms, time_params, x})
  end

  def mib_add(pid, _msg, time_params) do
    GenServer.call(pid, {:mib_add, time_params})
  end

  def mib_get_state(pid) do
    GenServer.call(pid, {:mib_get_state})
  end

  ## Server Callbacks
  @doc """
  """
  def init(state) do
    #:dets.open_file(:nw_events, [{:file, 'nw_events.txt'}, {:type, :duplicate_bag}])
    #:dets.insert(:nw_events, {0, 0, "Tx", :mib_recalc_40ms})
    Common_utils.add_event_db(0, 0, "NonRF", :mib_recalc_40ms, %{} )
    #:dets.insert(:nw_events, {0, 0, "Tx", :mib_add})
    Common_utils.add_event_db(0, 0, "Tx", :mib_add, %{} )

    #:dets.close(:nw_events)
    {:ok, state}
  end

  def handle_call({:mib_recalc_40ms, time_params, new_state}, _from, _state) do
    %{
      bw: bw,
      phich_mode: phich_mode,
      phich_ng: phich_ng,
      number_enodeb_tx_ant: number_enodeb_tx_ant
      } = new_state

    {:ok, pid} = Python.start(python_path: Path.expand(@python_dir))
    %{system_frame_no: system_frame_no, sfn: _sfn } = time_params
    mod4system_frame_no = div(system_frame_no, 4)
    Python.call(pid,
                "tdd_pbcch",
                "generate_mib",
                [bw, phich_mode, phich_ng, mod4system_frame_no, number_enodeb_tx_ant ])

    Python.stop(pid)
    {:reply, new_state, new_state}
  end


  def handle_call({:mib_add, time_params}, _from, state) do

    %{system_frame_no: system_frame_no, sfn: sfn } = time_params
    %{
      bw: bw,
      phich_mode: _,
      phich_ng: _,
      number_enodeb_tx_ant: _
      } = state

    {:ok, pid} = Python.start(python_path: Path.expand(@python_dir))
    Python.call(pid, "tdd_pbcch", "add_mib",  [system_frame_no, sfn, bw, 8 ])
    Python.call(pid, "tdd_pbcch", "add_mib",  [system_frame_no, sfn, bw, 9 ])
    Python.call(pid, "tdd_pbcch", "add_mib",  [system_frame_no, sfn, bw, 10 ])
    Python.call(pid, "tdd_pbcch", "add_mib",  [system_frame_no, sfn, bw, 11 ])
    Python.stop(pid)

    if rem(system_frame_no, 3) == 0 and system_frame_no != 0 do
      Common_utils.add_event_db(system_frame_no + 1, 0, "NonRF", :mib_recalc_40ms, %{} )
    end
    Common_utils.add_event_db(system_frame_no + 1, 0, "Tx", :mib_add, %{} )

    {:reply, state, state}

  end

  def handle_call({:mib_get_state}, _from, state) do
    {:reply, state, state}
  end

  ## Helper Functions


end
