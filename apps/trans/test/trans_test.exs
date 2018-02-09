defmodule TransTest do
  use ExUnit.Case
  alias Trans.Result

  defmodule TestBackend do
    def start_link(query, ref, owner, limit) do
      Task.start_link(__MODULE__, :fetch_result, [query, ref, owner, limit])
    end
    def fetch_result("result", ref, owner, _limit) do
      send(owner, {:results, ref, [%Result{backend: "test", text: "result"}]})
    end
    def fetch_result("none", ref, owner, _limit) do
      send(owner, {:results, ref, []})
    end
    def fetch_result("timeout", _ref, owner, _limit) do
      send(owner, {:backend, self()})
      :timer.sleep(:infinity)
    end
    def fetch_result("boom", _ref, _owner, _limit) do
      raise "boom!"
    end
  end

  test "translate/2 with backend results" do
    assert [%Result{backend: "test", text: "result"}] = Trans.translate("result", backends: [TestBackend])
  end

  test "translate/2 with no backend results" do
    assert [] = Trans.translate("none", backends: [TestBackend])
  end

  test "translate/2 with timeout returns no results and kills workers" do
    results = Trans.translate("timeout", backends: [TestBackend], timeout: 10)
    assert results == []
    assert_receive {:backend, backend_pid}
    ref = Process.monitor(backend_pid)
    assert_receive {:DOWN, ^ref, :process, _pis, _reason}
    refute_received {:DOWN, _, _, _, _}
    refute_received :timedout
  end

  @tag :capture_log
  test "translate/2 discards backend errors" do
    assert Trans.translate("boom", backends: [TestBackend]) == []
    refute_received {:DOWN, _, _, _, _}
    refute_received :timedout
  end

end
