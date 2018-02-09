defmodule Trans.Backend.PapagoNMTTest do
  use ExUnit.Case, async: true
  alias Trans.PapagoNMT

  test "makes request, reports results, then terminates" do
    ref = make_ref()
    {:ok, pid} = PapagoNMT.start_link("안녕하세요.", ref, self(), 1)
    Process.monitor(pid)

    # Default timeout of assert_receive is 100 milliseconds.
    assert_receive {:results, ^ref, [%Trans.Result{backend: "PapagoNMT", text: "Hello."}]}, 5_000
    assert_receive {:DOWN, _ref, :process, ^pid, :normal}
  end

  test "no query results reports and empty list" do
    ref = make_ref()
    {:ok, _} = PapagoNMT.start_link("", ref, self(), 1)

    assert_receive {:results, ^ref, []}, 5_000
  end

end