defmodule Agent_ue_pos do

  def start_link do
    Agent.start_link(fn ->   %{ coordinates: %{x_pos_mtr: 100, y_pos_mtr: 100},
                                velocity: %{x_vel_mtr: 0, y_vel_mtr: 0}
                              }
                    end)
  end

  def init_pos(pid, position) do
    Agent.update(pid, fn x-> Map.put(x, :coordinates, position)   end)
  end

  def init_vel(pid, velocity) do
    Agent.update(pid, fn x-> Map.put(x, :velocity, velocity)   end)
  end

  def set_new_pos_tti(pid, curr_tti, last_tti) do
    Agent.update(pid, fn x-> new_pos(x, curr_tti, last_tti)   end)
  end

  def get_ue_pos(pid) do
    Agent.get(pid, fn x->x  end)
  end

  defp new_pos(%{coordinates: c, velocity: v}, last_tti, curr_tti)
              when last_tti < curr_tti do
    %{x_pos_mtr: x, y_pos_mtr: y} = c
    %{x_vel_mtr: vx, y_vel_mtr: vy} = v
    new_c = %{x_pos_mtr: x + vx*(curr_tti - last_tti), y_pos_mtr:  y + vy*(curr_tti - last_tti)}
    %{coordinates: new_c, velocity: v}
  end
end
