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


  def add_event_db(system_frame_no, sfn, type, ue_id, event_tag, params ) do
    :dets.open_file(:nw_events, [{:file, 'nw_events.txt'}, {:type, :duplicate_bag}])
    :dets.insert(:nw_events, {system_frame_no, sfn, type, ue_id, event_tag, params})
    :dets.close(:nw_events)
  end


end
