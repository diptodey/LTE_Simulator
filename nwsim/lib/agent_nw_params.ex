defmodule Agent_nw_params do

  def start_link do
    Agent.start_link(fn -> %{ bw: 0,
                              config: 1,
                              total_no_carriers: 72,
                              phich_mode: 0,
                              phich_ng: 0,
                              number_enodeb_tx_ant: 1,
                              cell_number: 0,
                              cell_group_number: 0,
                              cfi: 1,
                            } end )
  end

  def get_param(pid, param) do
    Agent.get(pid, fn x-> x[param]   end)
  end


end
