defmodule Km do

  @type key :: binary()

  @spec keygen_from_entropy(entropy) ::
  {sk, pk} | {:error, String.t()}
  when entropy: binary(), pk: key(), sk: key()
  def keygen_from_entropy(entropy) do
    try do
      sk = BlockKeys.Mnemonic.generate_phrase(entropy) |> BlockKeys.from_mnemonic()
      {sk, BlockKeys.CKD.master_public_key(sk)}
    rescue
      e ->  {:error, "#{inspect(e)}"} ## TODO ERROR HANDLING
    end
  end

  @default_strength Application.get_env(:km, :key_strength, 256)

  @spec keygen(strength) ::
  {sk, pk, phrase, seed} | {:error, any()}
  when strength: integer(), sk: key(), pk: key(), phrase: String.t(), seed: String.t()
  def keygen(strength \\ @default_strength) do
    Task.async(fn ->

      phrase = Mnemo.generate(strength)
      entropy = Mnemo.entropy(phrase)

      case keygen_from_entropy(entropy) do
        {:error, _reason} = err -> err ## TODO ERROR HANDLING

        {sk, pk} ->
          {sk, pk, phrase, phrase |> Mnemo.seed}
      end

    end) |> Task.await()
  end

  # e.g. use "m/44'/0'/0'/0/0" (typical path for Eth)
  @spec derive(sk, path) ::
  sk | {:error, String.t()}
  when sk: key(), path: String.t()
  def derive(sk, path) do
    try do
      {:ok, BlockKeys.CKD.derive(sk, path)}
    rescue
      e -> {:error, "#{inspect(e)}"} ## TODO ERROR HANDLING
    end
  end

  @spec pk_from(sk) ::
  pk
  when sk: key(), pk: key()
  def pk_from("xprv" <> _ = sk) do
    BlockKeys.CKD.master_public_key(sk)
  end

end
