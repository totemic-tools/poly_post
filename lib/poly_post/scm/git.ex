defmodule PolyPost.Scm.Git do
  @moduledoc false

  # API

  def add!(path, specs) do
    File.cd!(path, fn -> run!(["add", specs]) end)
  end

  def checkout!(path, reference) do
    File.cd!(path, fn -> run!(["checkout", reference]) end)
  end

  def clone!(repo, path) do
    run!(["clone", repo, path])
  end

  def get_default_branch!(path) do
    File.cd!(path, fn -> run!(["rev-parse", "--abbrev-ref", "origin/HEAD"]) end)
  end

  def get_status!(path) do
    File.cd!(path, fn -> run!(["status", "-u", "--porcelain"]) end)
  end

  def pull!(path) do
    File.cd!(path, fn -> run!(["pull"]) end)
  end

  def stash!(path) do
    File.cd!(path, fn -> run!(["stash"]) end)
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
      {response, _} when is_binary(response) ->
        raise "The git command failed with reason: #{response}"
      _ ->
        raise "The git command failed with args: #{Enum.join(args, " ")}"
    end
  end
end
