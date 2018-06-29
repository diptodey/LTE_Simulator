defmodule User_utils do

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


  def add_event_db(table_name, user_id, system_frame_no, sfn, type, event_tag, params ) do
    :dets.open_file(table_name, [{:file, './../userid_#{user_id}_events.txt'}, {:type, :duplicate_bag}])
    :dets.insert(table_name, {system_frame_no, sfn, type, user_id, event_tag, params})
    :dets.close(table_name)
  end


end
