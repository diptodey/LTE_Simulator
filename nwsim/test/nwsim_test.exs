defmodule NwsimTest do
  use ExUnit.Case
  doctest Nwsim

  test "Test MIB" do
    {:ok, pid} = Nwsim.start_link()
    IO.puts("\n Frame = 0 SFN = 0")
    time_params = %{system_frame_no: 0, sfn: 0 }
    Nwsim.run_tx_events(pid, time_params)
    Nwsim.show_dbase()

    IO.puts("\n Frame = 0 SFN = 1")
    time_params = %{system_frame_no: 0, sfn: 1 }
    Nwsim.run_tx_events(pid, time_params)
    Nwsim.show_dbase()

    IO.puts("\n Frame = 1 SFN = 0")
    time_params = %{system_frame_no: 1, sfn: 0 }
    Nwsim.run_tx_events(pid, time_params)
    Nwsim.show_dbase()

    IO.puts("\n Frame = 1 SFN = 1")
    time_params = %{system_frame_no: 1, sfn: 1 }
    Nwsim.run_tx_events(pid, time_params)
    Nwsim.show_dbase()

    IO.puts("\n Frame = 2 SFN = 0")
    time_params = %{system_frame_no: 2, sfn: 0 }
    Nwsim.run_tx_events(pid, time_params)
    Nwsim.show_dbase()

    IO.puts("\n Frame = 2 SFN = 1")
    time_params = %{system_frame_no: 2, sfn: 1 }
    Nwsim.run_tx_events(pid, time_params)
    Nwsim.show_dbase()

    IO.puts("\n Frame = 3 SFN = 0")
    time_params = %{system_frame_no: 3, sfn: 0 }
    Nwsim.run_tx_events(pid, time_params)
    Nwsim.show_dbase()

    IO.puts("\n Frame = 3 SFN = 1")
    time_params = %{system_frame_no: 3, sfn: 1 }
    Nwsim.run_tx_events(pid, time_params)
    Nwsim.show_dbase()

    #Nwsim.add_event(pid, %{msg: :init_params, time_params: %{sfn: 0, system_frame_no: 0}})
  end


end
