defmodule Agent_user_params do

  def start_link do
    Agent.start_link(fn -> %{ bw: 0,
                              config: 0,
                              total_no_carriers: 0,
                              phich_mode: 0,
                              phich_ng: 0,
                              number_enodeb_tx_ant: 0,
                              cell_number: 0,
                              cell_group_number: 0,
                              cfi: 0,
                            } end )
  end

  def get_param(pid, param) do
    Agent.get(pid, fn x-> x[param]   end)
  end

  def update_param(pid, param, value) do
    Agent.update(pid, fn x -> x |> Map.put(param, value)  end)
  end

end
