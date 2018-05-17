defmodule ControllerTest do
  use ExUnit.Case
  doctest Controller

  test "Incr TTI " do
    {:ok, pid} = Agent_tti.start_link()
    assert Agent_tti.get_curr_tti(pid) == %{frame: 0, sfn: 0}
    for _ <- 1..9, do: Agent_tti.incr_tti(pid)
    assert Agent_tti.get_curr_tti(pid) == %{frame: 0, sfn: 9}
    Agent_tti.incr_tti(pid)
    assert Agent_tti.get_curr_tti(pid) == %{frame: 1, sfn: 0}
  end
end
