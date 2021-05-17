defmodule ExAuctionsManager.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate
  alias Ecto.Adapters.SQL.Sandbox
  alias Ecto.Changeset

  using do
    quote do
      alias ExAuctionsManager.Repo

      import Ecto
      import Ecto.Query
      import ExAuctionsManager.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Sandbox.checkout(ExAuctionsManager.Repo)

    unless tags[:async] do
      Sandbox.mode(ExAuctionsManager.Repo, {:shared, self()})
    end

    :ok
  end

  def errors_on(changeset) do
    Changeset.traverse_errors(changeset, fn {message, opts} ->
      Enum.reduce(opts, message, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
