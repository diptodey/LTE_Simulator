defmodule LogutilsTest do
  use ExUnit.Case
  doctest Logutils

  test "Write Line" do
    {:ok, pid} = Logutils.start_link()
    #Logutils.write_line(pid, "dipto")
    Logutils.write_line(pid, "3, 0, :Nw_Tx, 0, :sync_sss, %{cell_group_number: 0, cell_number: 0}")
    Logutils.write_line(pid, "3, 0, :Nw_Tx, 0, :sync_sss, %{cell_group_number: 0, cell_number: 10}")
    Logutils.write_line(pid, "3, 0, :Nw_Tx, 0, :sync_sss, %{cell_group_number: 0, cell_number: 100}")
    #IO.puts("dipto")
  end

end
