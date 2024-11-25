defmodule PolyPost.Builder do
  @moduledoc """
  A module used for building content from Markdown files (resources).

  When configured to use git or github, this will also retrieve
  content from the specified forge.
  """

  alias PolyPost.Resource
  alias PolyPost.Scm.{
    Git,
    Github
  }

  # API

  @doc """
  Builds a list of content for a specific marddown + metadata resource.
  """
  @doc since: "0.1.0"
  @spec build!(Resource.name()) :: [Resource.content()]
  def build!(resources), do: build_content!(resources)

  @doc """
  Builds all the content for each resource.
  """
  @doc since: "0.1.0"
  @spec build_all!() :: [{Resource.name(), [Resource.content()]}]
  def build_all! do
    Enum.map(get_content_keys_config(), fn resources ->
      {resources, build_content!(resources)}
    end)
  end

  # Private

  defp build_content!(resources) do
    opts = get_resources_config(resources)
    module = get_in(opts, [:module])
    paths = get_in(opts, [:path])
    dest = get_in(opts, [:source, :dest])
    git = get_in(opts, [:source, :git])
    github = get_in(opts, [:source, :github])
    ref = get_in(opts, [:source, :ref])
    fm_config = get_in(opts, [:front_matter]) || get_front_matter_config()

    cond do
      paths && !(git || github) ->
        build_via_paths!(module, fm_config, paths)
      dest && paths && (git || github) ->
        build_via_git!(module, fm_config, paths, dest, git, github, ref)
      :else ->
        []
    end
  end

  defp build_via_git!(module, fm_config, paths, dest, git, github, ref) do
    repo = git || Github.expand_repo(github)
    git_dir = Path.join(dest, ".git")

    if File.dir?(dest) && File.dir?(git_dir) do
      if Git.get_status!(dest) != "" do
        Git.stash!(dest)
      end
    else
      File.mkdir_p!(dest)
      Git.clone!(repo, dest)
    end

    Git.checkout!(dest, ref || Git.get_default_branch!(dest))
    Git.pull!(dest)

    build_via_paths!(module, fm_config, paths)
  end

  defp build_via_paths!(module, fm_config, paths, content \\ [])
  defp build_via_paths!(_module, _fm_config, [], content), do: content

  defp build_via_paths!(module, fm_config, path, content) when is_binary(path),
    do: build_via_paths!(module, fm_config, [path], content)

  defp build_via_paths!(module, fm_config, [path | paths], content) do
    new_content =
      path
      |> Path.wildcard()
      |> Enum.reduce(content, fn filepath, acc ->
        [build_via_specific_path!(module, fm_config, filepath) | acc]
      end)

    build_via_paths!(module, fm_config, paths, new_content)
  end

  defp build_via_specific_path!(module, fm_config, filepath) do
    filename = Path.basename(filepath)
    {metadata, body} = extract_content!(filepath, fm_config)
    apply(module, :build, [filename, metadata, body])
  end

  defp extract_content!(path, fm_config) do
    {raw_metadata, raw_content} = File.read!(path) |> extract_parts!()

    metadata = extract_metadata!(raw_metadata, fm_config)
    body = transform_all_content(raw_content)

    {metadata, body}
  end

  defp extract_metadata!(raw_metadata, fm_config) do
    {decoder, function, opts} = Keyword.get(fm_config, :decoder)

    case apply(decoder, function, [raw_metadata, opts]) do
      {:ok, metadata} ->
        metadata
      {:error, error} ->
        raise PolyPost.ParsingMetadataError, inspect(error)
    end
  end

  defp extract_parts!(content) do
    case String.split(content, ["---\n", "\n---\n", "\r\n---\r\n"], parts: 3) do
      [_, metadata, content] ->
        {metadata, content}
      _ ->
        raise PolyPost.MissingMetadataError, "Missing metadata at beginning of file."
    end
  end

  defp get_content_keys_config do
    :poly_post
    |> Application.fetch_env!(:resources)
    |> Keyword.get(:content)
    |> Keyword.keys()
  end

  defp get_front_matter_config do
    :poly_post
    |> Application.fetch_env!(:resources)
    |> Keyword.get(:front_matter)
  end

  defp get_resources_config(resources) do
    :poly_post
    |> Application.fetch_env!(:resources)
    |> get_in([:content, resources]) || []
  end

  defp transform_all_content(raw_content) do
    Earmark.as_html!(raw_content,
      escape: false,
      registered_processors: [{"code", &transform_code_content/1}]
    )
  end

  defp transform_code_content({_tag, attrs, content, _meta} = ast) do
    attr_list = Enum.flat_map(attrs, fn list -> Tuple.to_list(list) end)

    marker =
      Makeup.Registry.supported_language_names()
      |> Enum.find(&Enum.member?(attr_list, &1))

    case Makeup.Registry.fetch_lexer_by_name(marker) do
      {:ok, {lexer, opts}} ->
        new_content =
          content
          |> IO.iodata_to_binary()
          |> Makeup.highlight_inner_html(lexer: lexer, lexer_options: opts)

        {:replace, ~s(<code class="highlight">#{new_content}</code>)}

      :error ->
        ast
    end
  end
end
