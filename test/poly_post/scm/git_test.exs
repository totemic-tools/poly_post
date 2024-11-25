defmodule PolyPost.Scm.GitTest do
  use ExUnit.Case, async: false

  describe "add!/2" do
    test "adds any files specified as staged when in a git repo" do
      flunk "TBA"
    end

    test "errors when any attempting to add files when not in a git repo" do
      flunk "TBA"
    end
  end

  describe "checkout!/2" do
    test "checkouts a reference in a git repo" do
      flunk "TBA"
    end

    test "errors when checkouts a reference when not in a git repo" do
      flunk "TBA"
    end

    test "errors when checkouts a reference when in a git repo that does not exist" do
      flunk "TBA"
    end
  end

  describe "clone!/2" do
    test "clones a git repo into a path" do
      flunk "TBA"
    end

    test "errors when cloning a git repo onto an existing, non-empty path" do
      flunk "TBA"
    end

    test "errors when cloning a git repo that does not exist" do
      flunk "TBA"
    end
  end

  describe "get_default_branch!/1" do
    test "gets the default branch of a git repo" do
      flunk "TBA"
    end

    test "errors when getting the default branch in a path that is not a git repo" do
      flunk "TBA"
    end
  end

  describe "get_status!/1" do
    test "gets the status of a git repo" do
      flunk "TBA"
    end

    test "errors when getting the status of a path that is not a git repo" do
      flunk "TBA"
    end
  end

  describe "pull!/1" do
    test "pulls the current branch of a git repo" do
      flunk "TBA"
    end

    test "errors when pulling on reference that is not a branch on a git repo" do
      flunk "TBA"
    end

    test "errors when pulling on reference when not on a git repo" do
      flunk "TBA"
    end
  end

  describe "stash!/1" do
    test "stash any changes on a git  repo" do
      flunk "TBA"
    end

    test "errors when stashing when not on a git repo" do
      flunk "TBA"
    end
  end
end
