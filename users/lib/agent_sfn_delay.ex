defmodule Agent_sfn_delay do

  def start_link do
    Agent.start_link(fn -> %{conf0: {4,6,0,0,0,4,6,0,0,0}, #D 	S 	U 	U 	U 		D 	S 	U 	U 	U
                             conf1: {0,6,0,0,4,0,6,0,0,4}, #D 	S 	U 	U 	D 		D 	S 	U 	U 	D
                             conf2: {0,0,0,4,0,0,0,0,4,0}, #D 	S 	U 	D 	D 		D 	S 	U 	D 	D
                             conf3: {4,0,0,0,0,0,0,0,4,0}, #D 	S 	U 	U 	U 		D 	D 	D 	D 	D
                             conf4: {0,0,0,0,0,0,0,0,4,4}, #D 	S 	U 	U 	D 		D 	D 	D 	D 	D
                             conf5: {0,0,0,0,0,0,0,0,4,0}, #D 	S 	U 	D 	D 		D 	D 	D 	D 	D
                             conf6: {7,7,0,0,0,7,7,0,0,5}} #D 	S 	U 	U 	U 		D 	S 	U 	U 	D
                            end)
  end

  def get_sfn_delay(pid, config, sfn) do
      Agent.get(pid, fn x-> x[config] |> elem(sfn)  end)
  end

end
