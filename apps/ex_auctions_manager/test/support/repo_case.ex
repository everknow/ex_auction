defmodule ExAuctionsManager.RepoCase do
  use ExUnit.CaseTemplate
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
    :ok = Ecto.Adapters.SQL.Sandbox.checkout(ExAuctionsManager.Repo)

    unless tags[:async] do
      Ecto.Adapters.SQL.Sandbox.mode(ExAuctionsManager.Repo, {:shared, self()})
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
