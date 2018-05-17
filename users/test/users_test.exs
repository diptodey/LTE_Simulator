defmodule UsersTest do
  use ExUnit.Case
  doctest Users

  test "new pos" do
    {:ok, pid} = Agent_ue_pos.start_link()
    Agent_ue_pos.init_pos(pid, %{x_pos_mtr: 200, y_pos_mtr: 200})
    %{coordinates: c, velocity: _, } = Agent_ue_pos.get_ue_pos(pid)
    assert %{x_pos_mtr: 200, y_pos_mtr: 200} == c
    Agent_ue_pos.init_vel(pid, %{x_vel_mtr: 10, y_vel_mtr: 10})
    %{coordinates: c, velocity: v} = Agent_ue_pos.get_ue_pos(pid)
    assert %{x_pos_mtr: 200, y_pos_mtr: 200} == c
    assert %{x_vel_mtr: 10, y_vel_mtr: 10} == v
    Agent_ue_pos.set_new_pos_tti(pid, 0, 10)
    %{coordinates: c, velocity: _, } = Agent_ue_pos.get_ue_pos(pid)
    assert %{x_pos_mtr: 300, y_pos_mtr: 300} == c
  end


  test "sfn_delay" do
    {:ok, pid} = Agent_sfn_delay.start_link()
    assert 4 == Agent_sfn_delay.get_sfn_delay(pid, :conf0, 0)
    assert 6 == Agent_sfn_delay.get_sfn_delay(pid, :conf0, 1)
    assert 4 == Agent_sfn_delay.get_sfn_delay(pid, :conf0, 5)
    assert 6 == Agent_sfn_delay.get_sfn_delay(pid, :conf0, 6)
  end


  test "Tbs_calc" do
    assert 10 == Tbs_calc.get_itbs(10)
    assert 10 == Tbs_calc.get_itbs(11)
    assert 256 = Tbs_calc.get_tbs(0, 20)
  end

end
