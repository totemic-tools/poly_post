defmodule PolyPost.Scm.GithubTest do
  use ExUnit.Case, async: false
  use Mneme

  alias PolyPost.Scm.Github

  describe "expand_repo/1" do
    test "expands github repo shorcut to full URI" do
      auto_assert "https://github.com/totemic-tools/poly_post.git" <-
        Github.expand_repo("totemic-tools/poly_post")
    end
  end
end
