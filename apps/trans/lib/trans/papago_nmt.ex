defmodule Trans.PapagoNMT do
  alias Trans.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query_str, query_ref, owner, _limit) do
    query_str
    |> fetch_json()
    # |> xpath(~x"/queryresult/pod[contains(@title, 'Result') or contains(@title, 'Definitions')]/subpod/plaintext/text()")
    |> send_results(query_ref, owner)
  end

  defp send_results(nil, query_ref, owner) do
    send(owner, {:results, query_ref, []})
  end
  defp send_results(translation, query_ref, owner) do
    results = [%Result{backend: "PapagoNMT", text: to_string(translation)}]
    send(owner, {:results, query_ref, results})
  end

  @http Application.get_env(:trans, :papago_nmt)[:http_client] || :httpc
  defp fetch_json(query_str) do

    # TODO : Implement PapagoNMT API
    # request = {
    #   String.to_charlist("http://openapi.naver.com/v1/papago/n2mt?source=ko&target=en&text=#{URI.encode(query_str)}"), 
    #   [
    #     {'Content-Type', 'application/x-www-form-urlencoded; charset=UTF-8'},
    #     {'X-Naver-Client-Id', String.to_charlist(Application.get_env(:trans, :papago_nmt)[:client_id])},
    #     {'X-Naver-Client-Secret', String.to_charlist(Application.get_env(:trans, :papago_nmt)[:client_secret])}
    #   ]
    # }
    # {:ok, {_, _, body}} = @http.request(:get, request, [], [])
    body = "This is the hard-coded translation."
    body
  end
end