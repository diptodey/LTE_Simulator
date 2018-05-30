defmodule NwsimTest do
  use ExUnit.Case
  doctest Nwsim

  test "Test MIB" do
    {:ok, pid} = Nwsim.start_link()

    sfn_list = [0,1,2,3,4,5,6,7,8,9]
    frame_list = [0,1,2,3,4]

    for frame <- frame_list do
      for sfn <- sfn_list do
        time_params = %{system_frame_no: frame, sfn: sfn }
        Nwsim.run_tx_events(pid, time_params)
      end
    end
    Nwsim.show_dbase()



    #Nwsim.add_event(pid, %{msg: :init_params, time_params: %{sfn: 0, system_frame_no: 0}})
  end

end
