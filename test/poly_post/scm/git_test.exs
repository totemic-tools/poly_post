defmodule PolyPost.Scm.GitTest do
  use ExUnit.Case, async: false
  use Mneme

  alias PolyPost.GitTestHelper
  alias PolyPost.Scm.Git

  describe "add!/2" do
    test "adds any files specified as staged when in a git repo" do
      path = GitTestHelper.setup_tmp_repo()

      System.cmd("touch", [Path.join(path, "file.txt")])

      auto_assert "" <- Git.add!(path, ".")
      auto_assert "A  file.txt\n" <- Git.get_status!(path)
    end

    test "errors when any attempting to add files when not in a git repo" do
      path = GitTestHelper.random_tmp_dir()

      System.cmd("touch", [Path.join(path, "file.txt")])

      assert_raise RuntimeError, "The git command failed with reason: 128", fn ->
        Git.add!(path, ".")
      end
    end
  end

  describe "checkout!/2" do
    test "checkouts a reference in a git repo" do
      path = GitTestHelper.setup_tmp_repo()
      GitTestHelper.make_test_commit(path)

      auto_assert "" <- Git.checkout!(path, "main")
    end

    test "errors when checkouts a reference that is not in a git repo" do
      path = GitTestHelper.setup_tmp_repo()

      assert_raise RuntimeError, "The git command failed with reason: 1", fn ->
        Git.checkout!(path, "main")
      end
    end

    test "errors when checkouts a reference when not in a git repo" do
      path = GitTestHelper.random_tmp_dir()

      assert_raise RuntimeError, "The git command failed with reason: 128", fn ->
        Git.checkout!(path, "main")
      end
    end
  end

  describe "clone!/2" do
    setup do
      {:ok, source: GitTestHelper.setup_tmp_repo()}
    end

    test "clones a git repo into a path", %{source: source} do
      path = GitTestHelper.random_tmp_dir()
      auto_assert "" <- Git.clone!(source, path)
    end

    test "errors when cloning a git repo that does not exist" do
      assert_raise RuntimeError, "The git command failed with reason: 128", fn ->
        Git.clone!(GitTestHelper.random_string(), System.tmp_dir())
      end
    end
  end

  describe "get_default_branch!/1" do
    test "gets the default branch of a git repo" do
      path = GitTestHelper.setup_tmp_repo()
      GitTestHelper.make_test_commit(path)

      auto_assert "main" <- Git.get_default_branch!(path)
    end

    test "errors when getting the default branch in a path that is not a git repo" do
      path = GitTestHelper.random_tmp_dir()

      assert_raise RuntimeError, "The git command failed with reason: 128", fn ->
        Git.get_default_branch!(path)
      end
    end
  end

  describe "get_status!/1" do
    test "gets the status of a git repo" do
      path = GitTestHelper.setup_tmp_repo()
      auto_assert "" <- Git.get_status!(path)
    end

    test "errors when getting the status of a path that is not a git repo" do
      path = GitTestHelper.random_tmp_dir()

      assert_raise RuntimeError, "The git command failed with reason: 128", fn ->
        Git.get_status!(path)
      end
    end
  end

  describe "pull!/1" do
    setup do
      source = GitTestHelper.setup_tmp_repo()
      GitTestHelper.make_test_commit(source)

      {:ok, source: source}
    end

    test "pulls the current branch of a git repo", %{source: source} do
      path = GitTestHelper.random_tmp_dir()
      Git.clone!(source, path)

      auto_assert "Already up to date.\n" <- Git.pull!(path)
    end

    test "errors when pulling on reference when not on a git repo" do
      path = GitTestHelper.random_tmp_dir()

      assert_raise RuntimeError, "The git command failed with reason: 128", fn ->
        Git.pull!(path)
      end
    end
  end

  describe "stash!/1" do
    test "stash any changes on a git repo" do
      path = GitTestHelper.setup_tmp_repo()
      GitTestHelper.make_test_commit(path)

      System.cmd("touch", [Path.join(path, "file2.txt")])

      auto_assert "?? file2.txt\n" <- Git.get_status!(path)
      assert String.starts_with?(Git.stash!(path), "Saved working directory")
      auto_assert "" <- Git.get_status!(path)
    end

    test "errors when stashing when not on a git repo" do
      path = GitTestHelper.random_tmp_dir()

      assert_raise RuntimeError, "The git command failed with reason: 128", fn ->
        Git.stash!(path)
      end
    end
  end
end
