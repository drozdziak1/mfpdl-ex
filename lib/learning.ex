defmodule Learning do
  @moduledoc """
  Documentation for `Learning`.
  """
  @doc """
  Hello world.

  ## Examples

      iex> Learning.hello()
      :world

  """
  @mfp_url "https://musicforprogramming.net/"
  def find_ep_page_links do
    {:ok, _status, _headers, client} = :hackney.request(@mfp_url <> "latest")
    {:ok, body} = :hackney.body(client)
    {:ok, html} = Floki.parse_document(body)
    # Remove RSS links
    [_rss1, _rss2 | links]= Floki.find(html, "#sapper a")
    # Remove /about and /credits
    links = links |> Enum.reverse() |> tl() |> tl()
    Enum.map(links, fn entry ->
      {_a, [{"href", link}], _contents} = entry
      @mfp_url <> link
    end)
  end

  def get_mp3_link(url) do
    IO.puts("Processing url #{url}")
    {:ok, _status, _headers, client} = :hackney.request(url)
    {:ok, body} = :hackney.body(client)
    {:ok, html} = Floki.parse_document(body)
    [_analytics, sapper] = Floki.find(html, "script")
    [src] = elem(sapper, 2)
    [_, escaped_url] = Regex.run(~r/file:(?<url>".+"),/U, src, [])
    Jason.decode(escaped_url)
  end

  def get_all_mp3_links do
    links = find_ep_page_links()
    s = Task.async_stream(links, fn l -> get_mp3_link(l) end, [])
    Enum.reduce(s, [], fn {:ok, link}, acc -> acc ++ [link] end)
  end
end
