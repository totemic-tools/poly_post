defmodule PolyPost.GitTestHelper do
  alias PolyPost.Scm.Git

  def make_test_commit(path) do
    source = File.cwd!() |> Path.join("test/support/git_test_content.md")
    System.cmd("cp", [source, path])

    Git.add!(path, ".")
    File.cd!(path, fn -> System.cmd("git", ["commit", "-m", "\"test\""]) end)
  end

  def random_string do
    :rand.bytes(8) |> Base.encode64(padding: false)
  end

  def random_tmp_dir do
    System.tmp_dir()
    |> Path.join(random_string())
    |> tap(fn path -> System.cmd("mkdir", ["-p", path]) end)
  end

  def setup_tmp_repo do
    tap(random_tmp_dir(), fn path ->
      System.cmd("git", ["init", path, "-b", "main", "--quiet"])
    end)
  end
end
