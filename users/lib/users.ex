defmodule Users do
  @moduledoc """
  Documentation for Users.
  """

  use GenServer

  ## Client API

  @doc """

  """
  def start_link(user_id) do
    GenServer.start_link(__MODULE__, [user_id])
  end


  def run_rx_events(pid, rx_params, time_params) do
      rx_params |> Enum.map( fn(rx_params) -> GenServer.call(pid, {Enum.at(rx_params, 0), Enum.at(rx_params, 1), time_params })  end)
  end

## Server Callbacks
  def init(user_id) do
    {:ok,
    user_id
    }
  end


  def handle_call({:mib, _msg, _time_params}, _from, state ) do
      {:reply, state, state}
  end


  def handle_call({:sync_pss, _msg, _time_params}, _from, state ) do
    {:reply, state, state}
  end


  def handle_call({:sync_sss, _msg, _time_params}, _from, state ) do
    {:reply, state, state}
  end


  def handle_call({:pcfich, _msg, _time_params}, _from, state) do
    {:reply, state, state}
  end
  ## Server API



end
