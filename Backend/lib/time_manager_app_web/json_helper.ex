defmodule TimeManagerAppWeb.JSONHelper do
  @moduledoc """
  Provides helper functions for JSON rendering in controllers.
  """

  @doc """
  Renders a single item.
  """
  def render_item(item) when is_tuple(item) do
    Tuple.to_list(item)
  end

  def render_item(item) when is_struct(item) do
    item
    |> Map.from_struct()
    |> Map.drop([:__meta__, :__struct__])
    |> Enum.reduce(%{}, fn
      {:members, members}, acc when is_list(members) ->
        Map.put(acc, :members, render_list(members))
      {:manager, manager}, acc when not is_nil(manager) ->
        Map.put(acc, :manager, render_item(manager))
      {_key, %Ecto.Association.NotLoaded{}}, acc ->
        acc
      {key, value}, acc ->
        Map.put(acc, key, render_item(value))
    end)
  end

  def render_item(item) when is_map(item) do
    Enum.reduce(item, %{}, fn {key, value}, acc ->
      Map.put(acc, key, render_item(value))
    end)
  end

  def render_item(item) when is_list(item) do
    Enum.map(item, &render_item/1)
  end

  def render_item(item), do: item

  @doc """
  Renders a list of items.
  """
  def render_list(items) when is_list(items) do
    Enum.map(items, &render_item/1)
  end

  @doc """
  Renders changeset errors.
  """
  def render_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  defp translate_error({msg, opts}) do
    Enum.reduce(opts, msg, fn {key, value}, acc ->
      String.replace(acc, "%{#{key}}", fn _ -> to_string(value) end)
    end)
  end

  @doc """
  Renders a team with its members.
  """
  def render_team_with_members(team) do
    team
    |> render_item()
    |> Map.put(:members, render_team_members(team.members))
  end

  @doc """
  Renders team members.
  """
  def render_team_members(members) when is_list(members) do
    Enum.map(members, fn member ->
      render_item(%{
        id: member.id,
        username: member.username,
        email: member.email,
        inserted_at: member.inserted_at,
        updated_at: member.updated_at
      })
    end)
  end
  def render_team_members(_), do: []
end
