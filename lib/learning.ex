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
    [_rss1, _rss2 | links] = Floki.find(html, "#sapper a")
    links
  end

  def get_mp3_link(url) do
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

  end
end
