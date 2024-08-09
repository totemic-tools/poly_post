defmodule PolyPost.Builder do
  alias PolyPost.Depot

  # API

  @spec build!(atom()) :: :ok
  def build!(resource) do
    resource
    |> build_content!()
    |> save_content(resource)

    :ok
  end

  @spec build_all!() :: :ok
  def build_all! do
    Enum.map(get_config(), fn resource ->
      build_content!(resource) |> save_content(resource)
    end)

    :ok
  end

  @spec build_via_paths!(module(), Path.t | [Path.t]) :: [struct()]
  def build_via_paths!(module, paths, content \\ [])
  def build_via_paths!(_module, [], content), do: content
  def build_via_paths!(module, path, content) when is_binary(path), do: build_via_paths!(module, [path], content)
  def build_via_paths!(module, [path|paths], content) do
    new_content = path
    |> Path.wildcard()
    |> Enum.reduce(content, fn filepath, acc -> [build_via_filepath!(module, filepath) | acc] end)

    build_via_paths!(module, paths, new_content)
  end

  @spec build_via_filepath!(module(), Path.t) :: struct()
  def build_via_filepath!(module, filepath) do
    filename = Path.basename(filepath)
    {metadata, body} = extract_content!(filepath)
    apply(module, :build, [filename, metadata, body])
  end

  # Private

  defp build_content!(resource) do
    case get_config(resource) do
      {module, {:path, paths}} -> build_via_paths!(module, paths)
      _ -> :ok
    end
  end

  defp extract_content!(path) do
    {raw_metadata, raw_content} = File.read!(path) |> extract_parts!()

    metadata = extract_metadata!(raw_metadata)
    body = transform_all_content(raw_content)

    {metadata, body}
  end

  def extract_metadata!(raw_metadata) do
    case Jason.decode(raw_metadata) do
      {:ok, metadata} -> metadata
      {:error, error} -> raise error
    end
  end

  def extract_parts!(content) do
    case String.split(content, ["\n---\n", "\r\n---\r\n"], parts: 2) do
      [metadata, content] -> {metadata, content}
      _ -> raise PolyPost.MissingMetadataError, "Missing metadata at beginning of file."
    end
  end

  defp get_config do
    Application.fetch_env!(:poly_post, :resources)
  end

  defp get_config(resource) do
    get_config() |> get_in([:content, resource])
  end

  defp save_content(content, resource) do
    Enum.each(content, fn %{key: key} = data ->
      Depot.insert(resource, key, data)
    end)
  end

  defp transform_all_content(raw_content) do
    Earmark.as_html!(raw_content, escape: false, registered_processors: [{"code", &transform_code_content/1}])
  end

  defp transform_code_content({_tag, attrs, content, _meta} = ast) do
    attr_list = Enum.flat_map(attrs, fn list -> Tuple.to_list(list) end)

    marker = Makeup.Registry.supported_language_names()
    |> Enum.find(&(Enum.member?(attr_list, &1)))

    case Makeup.Registry.fetch_lexer_by_name(marker) do
      {:ok, {lexer, opts}} ->
        new_content = content
        |> IO.iodata_to_binary()
        |> Makeup.highlight_inner_html(lexer: lexer, lexer_options: opts)

        {:replace, ~s(<code class="highlight">#{new_content}</code>)}
      :error ->
        ast
    end
  end
end
