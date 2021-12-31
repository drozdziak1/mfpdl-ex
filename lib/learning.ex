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
  def hello do
    {:ok, _status, _headers, client} = :hackney.request("musicforprogramming.net/latest")
    {:ok, body} = :hackney.body(client)
    {:ok, html} = Floki.parse_document(body)
    html
  end
end
