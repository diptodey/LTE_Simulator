defmodule Common_utils do

  def delete_file_if_exists?(filename) do
    if File.exists?(filename) do
      case File.rm(filename) do
        :ok -> "ok"
        {:error, _} -> "error"
      end
    else
      "ok"
    end
  end

end
