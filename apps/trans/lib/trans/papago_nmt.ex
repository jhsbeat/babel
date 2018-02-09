defmodule Trans.PapagoNMT do
  alias Trans.Result

  def start_link(query, query_ref, owner, limit) do
    Task.start_link(__MODULE__, :fetch, [query, query_ref, owner, limit])
  end

  def fetch(query_str, query_ref, owner, _limit) do
    query_str
    |> fetch_result()
    |> send_results(query_ref, owner)
  end

  defp send_results(nil, query_ref, owner) do
    send(owner, {:results, query_ref, []})
  end
  defp send_results(translation, query_ref, owner) do
    results = [%Result{backend: "PapagoNMT", text: to_string(translation)}]
    send(owner, {:results, query_ref, results})
  end

  defp fetch_result(query_str) do
    url = "https://openapi.naver.com/v1/papago/n2mt"
    body = [
      source: "ko",
      target: "en",
      text: query_str
    ]
    headers = [
      "Content-Type": "application/x-www-form-urlencoded; charset=UTF-8",
      "X-Naver-Client-Id": Application.get_env(:trans, :papago_nmt)[:client_id],
      "X-Naver-Client-Secret": Application.get_env(:trans, :papago_nmt)[:client_secret]
    ]
    options = [ssl: [{:versions, [:'tlsv1.2']}], recv_timeout: 500]

    case HTTPoison.request(:post, url, {:form, body}, headers, options) do
      {:ok, %HTTPoison.Response{} = response} -> 
        {:ok, map} = response.body |> Poison.decode()
        map["message"]["result"]["translatedText"]
      {:error, %HTTPoison.Error{} = error} -> 
        {:error, error}
    end
  end
end