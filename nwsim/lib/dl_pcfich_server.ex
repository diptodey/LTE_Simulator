defmodule Dl_pcfich_server do

  use GenServer
  use Export.Python

  #@python_dir "./../python_lib"
  ## Client API
  @doc """
  """
  def start_link(state) do
    GenServer.start_link(__MODULE__,  state)
  end

  def pcfich_add(pid, _msg, time_params) do
    GenServer.call(pid, {:pcfich, time_params})
  end

  def pcfich_get_state(pid) do
    GenServer.call(pid, {:pcfich_get_state})
  end

  ## Server Callbacks
  @doc """
  """
  def init(state) do
    #%{cfi: _, config: config} = state
    Common_utils.add_event_db(0, 0, "Nw_Tx", 0, :pcfich, %{} )
    {:ok, state}
  end


  def handle_call({:pcfich, time_params}, _from, state) do
    find_next_DL(time_params, state[:config])
    {:reply, state, state}
  end

  def handle_call({:pcfich_get_state}, _from, state) do
    {:reply, state, state}
  end

  ## Helper Functions

  #D 	S 	U 	U 	U 		D 	S 	U 	U 	U
  defp find_next_DL(%{system_frame_no: system_frame_no, sfn: sfn }, _config = 0) do
    case sfn do
      0 -> schedule_next(system_frame_no, 4)
      5 -> schedule_next(system_frame_no + 1, 0)
    end
  end

  #D 	S 	U 	U 	D 		D 	S 	U 	U 	D
  defp find_next_DL(%{system_frame_no: system_frame_no, sfn: sfn }, _config = 1) do
    case sfn do
      0 -> schedule_next(system_frame_no, 4)
      4 -> schedule_next(system_frame_no, 5)
      5 -> schedule_next(system_frame_no, 9)
      9 -> schedule_next(system_frame_no + 1, 0)
    end

  end

  #D 	S 	U 	D 	D 		D 	S 	U 	D 	D
  defp find_next_DL(%{system_frame_no: system_frame_no, sfn: sfn }, _config = 2) do
    case sfn do
      0 -> schedule_next(system_frame_no, 3)
      3 -> schedule_next(system_frame_no, 4)
      4 -> schedule_next(system_frame_no, 5)
      5 -> schedule_next(system_frame_no, 8)
      8 -> schedule_next(system_frame_no, 9)
      9 -> schedule_next(system_frame_no + 1, 0)
    end
  end

  #D 	S 	U 	U 	U 		D 	D 	D 	D 	D
  defp find_next_DL(%{system_frame_no: system_frame_no, sfn: sfn }, _config = 3) do
    case sfn do
      0 -> schedule_next(system_frame_no, 5)
      5 -> schedule_next(system_frame_no, 6)
      6 -> schedule_next(system_frame_no, 7)
      7 -> schedule_next(system_frame_no, 8)
      8 -> schedule_next(system_frame_no, 9)
      9 -> schedule_next(system_frame_no + 1, 0)

    end
  end

  #D 	S 	U 	U 	D 		D 	D 	D 	D 	D
  defp find_next_DL(%{system_frame_no: system_frame_no, sfn: sfn }, _config = 4) do
    case sfn do
      0 -> schedule_next(system_frame_no, 4)
      4 -> schedule_next(system_frame_no, 5)
      5 -> schedule_next(system_frame_no, 6)
      6 -> schedule_next(system_frame_no, 7)
      7 -> schedule_next(system_frame_no, 8)
      8 -> schedule_next(system_frame_no, 9)
      9 -> schedule_next(system_frame_no + 1, 0)
    end
  end

  #D 	S 	U 	D 	D 		D 	D 	D 	D 	D
  defp find_next_DL(%{system_frame_no: system_frame_no, sfn: sfn }, _config = 5) do
    case sfn do
      0 -> schedule_next(system_frame_no, 3)
      3 -> schedule_next(system_frame_no, 4)
      4 -> schedule_next(system_frame_no, 5)
      5 -> schedule_next(system_frame_no, 6)
      6 -> schedule_next(system_frame_no, 7)
      7 -> schedule_next(system_frame_no, 8)
      8 -> schedule_next(system_frame_no, 9)
      9 -> schedule_next(system_frame_no + 1, 0)
    end
  end

  #D 	S 	U 	U 	U 		D 	S 	U 	U 	D
  defp find_next_DL(%{system_frame_no: system_frame_no, sfn: sfn }, _config = 6) do
    case sfn do
      0 -> schedule_next(system_frame_no, 5)
      5 -> schedule_next(system_frame_no, 9)
      9 -> schedule_next(system_frame_no + 1, 0)
    end
  end

  defp schedule_next(system_frame_no, sfn) do
    Common_utils.add_event_db(system_frame_no, sfn, "Nw_Tx", 0, :pcfich, %{} )
  end

end
