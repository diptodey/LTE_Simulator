defmodule Users do
  @moduledoc """
  Documentation for Users.
  """

  use GenServer

  def start_link() do
    GenServer.start_link(__MODULE__, :ok, [])
  end

  def get_state(pid) do
    GenServer.call(pid, {:get_state})
  end

  def send_pucch(_pid, _from) do

  end

  def recv_pdch(_pid, _from) do

  end

  def send_pusch(_pid, _from) do

  end

  def init(:ok) do
    {:ok,
    %{
      last_update_tti: 0
      }
    }
  end


  ## Server API



end
