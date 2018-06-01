defmodule Agent_tti do

  def start_link do
    Agent.start_link(fn -> %{system_frame_no: 0, sfn: 0 } end)
  end

  def get_curr_tti(pid) do
    Agent.get(pid, fn x->x  end)
  end

  def incr_tti(pid) do
    Agent.update(pid, &get_next_fn_sfn/1)
  end

  defp get_next_fn_sfn(%{system_frame_no: x, sfn: 9  }), do: %{system_frame_no: x+1, sfn: 0}
  defp get_next_fn_sfn(%{system_frame_no: x, sfn: y}) when y < 19 and y >= 0, do: %{system_frame_no: x, sfn: y+1}

end
