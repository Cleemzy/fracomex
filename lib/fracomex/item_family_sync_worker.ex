defmodule Fracomex.ItemFamilySyncWorker do
  use GenServer
  alias Fracomex.SyncLogic

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  def init(state) do
    recurrent_sync(state)
    {:ok, state}
  end

  defp recurrent_sync(_state) do
    SyncLogic.sync_item_families()
    Process.send_after(self(), :redo_sync,  10 * 1000)
  end

  def handle_info(:redo_sync, state) do
    recurrent_sync(state)
    {:noreply, state}
  end

end
