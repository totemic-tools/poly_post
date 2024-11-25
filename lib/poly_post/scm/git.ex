defmodule PolyPost.Scm.Git do
  @moduledoc false

  # API

  def add!(path, specs) do
    File.cd!(path, fn -> run!(["add", specs]) end)
  end

  def checkout!(path, reference) do
    File.cd!(path, fn -> run!(["checkout", reference, "--quiet"]) end)
  end

  def clone!(repo, path) do
    run!(["clone", repo, path])
  end

  def get_default_branch!(path) do
    path
    |> File.cd!(fn -> run!(["rev-parse", "--abbrev-ref", "HEAD"]) end)
    |> String.trim()
  end

  def get_status!(path) do
    File.cd!(path, fn -> run!(["status", "-u", "--porcelain"]) end)
  end

  def pull!(path) do
    File.cd!(path, fn -> run!(["pull"]) end)
  end

  def stash!(path) do
    File.cd!(path, fn ->
      add!(path, ".")
      run!(["stash"])
    end)
  end

  # Private

  defp run!(args) do
    try do
      System.cmd("git", args)
    catch
      :error, :enoent ->
        raise "The git command was not found."
    else
      {response, 0} ->
        response
      {response, status} when is_binary(response) ->
        reason = String.trim(response <> " " <> inspect(status))
        raise "The git command failed with reason: #{reason}"
      _ ->
        raise "The git command failed with args: #{Enum.join(args, " ")}"
    end
  end
end
