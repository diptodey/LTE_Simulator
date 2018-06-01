defmodule ControllerTest do
  use ExUnit.Case
  doctest Controller

  test "Incr TTI " do
    {:ok, pid} = Agent_tti.start_link()
    assert Agent_tti.get_curr_tti(pid) == %{system_frame_no: 0, sfn: 0}
    for _ <- 1..9, do: Agent_tti.incr_tti(pid)
    assert Agent_tti.get_curr_tti(pid) == %{system_frame_no: 0, sfn: 9}
    Agent_tti.incr_tti(pid)
    assert Agent_tti.get_curr_tti(pid) == %{system_frame_no: 1, sfn: 0}
  end


  test "Controller" do
    {:ok, pid} = Controller.start_link()
    sfn_list = [0,1,2,3,4,5,6,7,8,9]
    frame_list = [0,1,2,3,4]
    for frame <- frame_list do
      for sfn <- sfn_list do
        Controller.run_next_tti(pid)
      end
    end
    Nwsim.show_dbase()
  end

end
