defmodule TimeManagerApp.TimeTracking do
  @moduledoc """
  The TimeTracking context.
  """

  import Ecto.Query, warn: false
  alias TimeManagerApp.Repo
  alias TimeManagerApp.TimeTracking.WorkingTime
  alias TimeManagerApp.TimeTracking.Clock
  alias TimeManagerApp.TimeTracking.TeamWorkingTime
  alias TimeManagerApp.TimeTracking.TeamClock

  @doc """
  Returns the list of working times for a user within a date range.

  ## Examples

      iex> list_working_times(1, ~N[2023-01-01 00:00:00], ~N[2023-12-31 23:59:59])
      [%WorkingTime{}, ...]

  """

  def list_working_times(0, start_date, end_date) do
    WorkingTime
    |> where([w], w.start >= ^start_date and w.end <= ^end_date)
    |> Repo.all()
  end

  def list_working_times(user_id, start_date, end_date) do
    WorkingTime
    |> where([w], w.user_id == ^user_id)
    |> where([w], w.start >= ^start_date and w.end <= ^end_date)
    |> Repo.all()
  end


  @doc """
  Returns the list of working times for a specefic user
  """
  def list_working_times_user(user_id) do
    WorkingTime
    |> where([w], w.user_id == ^user_id and not is_nil(w.user_id))
    |> Repo.all()
  end

  @doc """
  Returns the list of all working times.

  ## Examples

      iex> list_all_working_times()
      [%WorkingTime{}, ...]

  """
  def list_all_working_times do
    Repo.all(WorkingTime)
  end

  @doc """
  Gets a single working time.

  Raises `Ecto.NoResultsError` if the WorkingTime does not exist.

  ## Examples

      iex> get_working_time!(123)
      %WorkingTime{}

      iex> get_working_time!(456)
      ** (Ecto.NoResultsError)

  """
  def get_working_time!(id), do: Repo.get!(WorkingTime, id)

  @doc """
  Gets a single working time for a specific user.

  Raises `Ecto.NoResultsError` if the WorkingTime does not exist.

  ## Examples

      iex> get_working_time!(123, 1)
      %WorkingTime{}

      iex> get_working_time!(456, 1)
      ** (Ecto.NoResultsError)

  """
  def get_working_time!(id, user_id) do
    WorkingTime
    |> where([w], w.id == ^id and w.user_id == ^user_id)
    |> Repo.one!()
  end

  @doc """
  Creates a working time.

  ## Examples

      iex> create_working_time(1, %{field: value})
      {:ok, %WorkingTime{}}

      iex> create_working_time(1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_working_time(user_id, attrs \\ %{}) do
    %WorkingTime{}
    |> WorkingTime.changeset(Map.put(attrs, "user_id", user_id))
    |> Repo.insert()
  end

  @doc """
  Updates a working time.

  ## Examples

      iex> update_working_time(working_time, %{field: new_value})
      {:ok, %WorkingTime{}}

      iex> update_working_time(working_time, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_working_time(%WorkingTime{} = working_time, attrs) do
    working_time
    |> WorkingTime.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a working time.

  ## Examples

      iex> delete_working_time(working_time)
      {:ok, %WorkingTime{}}

      iex> delete_working_time(working_time)
      {:error, %Ecto.Changeset{}}

  """
  def delete_working_time(%WorkingTime{} = working_time) do
    Repo.delete(working_time)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking working time changes.

  ## Examples

      iex> change_working_time(working_time)
      %Ecto.Changeset{data: %WorkingTime{}}

  """
  def change_working_time(%WorkingTime{} = working_time, attrs \\ %{}) do
    WorkingTime.changeset(working_time, attrs)
  end

    @doc """
  Returns the list of all clocks.

  ## Examples

      iex> list_all_clocks()
      [%Clock{}, ...]

  """
  def list_all_clocks do
    Repo.all(Clock)
  end

  @doc """
  Returns the list of clocks for a user.

  ## Examples

      iex> list_clocks(1)
      [%Clock{}, ...]

  """
  def list_clocks(user_id) do
    Clock
    |> where([c], c.user_id == ^user_id)
    |> Repo.all()
  end

  @doc """
  Gets a single clock.

  Raises `Ecto.NoResultsError` if the Clock does not exist.

  ## Examples

      iex> get_clock!(123)
      %Clock{}

      iex> get_clock!(456)
      ** (Ecto.NoResultsError)

  """
  def get_clock!(id), do: Repo.get!(Clock, id)

  @doc """
  Creates a clock.

  ## Examples

      iex> create_clock(1, %{field: value})
      {:ok, %Clock{}}

      iex> create_clock(1, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_clock(user_id, attrs \\ %{}) do
    %Clock{}
    |> Clock.changeset(Map.put(attrs, "user_id", user_id))
    |> Repo.insert()
  end

  @doc """
  Updates a clock.

  ## Examples

      iex> update_clock(clock, %{field: new_value})
      {:ok, %Clock{}}

      iex> update_clock(clock, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_clock(%Clock{} = clock, attrs) do
    clock
    |> Clock.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a clock.

  ## Examples

      iex> delete_clock(clock)
      {:ok, %Clock{}}

      iex> delete_clock(clock)
      {:error, %Ecto.Changeset{}}

  """
  def delete_clock(%Clock{} = clock) do
    Repo.delete(clock)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking clock changes.

  ## Examples

      iex> change_clock(clock)
      %Ecto.Changeset{data: %Clock{}}

  """
  def change_clock(%Clock{} = clock, attrs \\ %{}) do
    Clock.changeset(clock, attrs)
  end

  # Team Working Times functions
  def list_team_working_times(team_id, start_date, end_date) do
    TeamWorkingTime
    |> where([w], w.team_id == ^team_id)
    |> where([w], w.start >= ^start_date and w.end <= ^end_date)
    |> Repo.all()
  end

  # get all teams working times without params start and end
    @doc """
  Returns the list of all team working times.
  """
  def list_all_team_working_times do
    TeamWorkingTime
    |> Repo.all()
    |> Repo.preload(:team)
  end

   @doc """
  Returns the list of all team clocks.
  """
  def list_all_team_clocks do
    TeamClock
    |> Repo.all()
    |> Repo.preload(:team)
  end

  def get_team_working_time!(id), do: Repo.get!(TeamWorkingTime, id)

  def create_team_working_time(team_id, attrs \\ %{}) do
    %TeamWorkingTime{}
    |> TeamWorkingTime.changeset(Map.put(attrs, "team_id", team_id))
    |> Repo.insert()
  end

  def update_team_working_time(%TeamWorkingTime{} = team_working_time, attrs) do
    team_working_time
    |> TeamWorkingTime.changeset(attrs)
    |> Repo.update()
  end

  def delete_team_working_time(%TeamWorkingTime{} = team_working_time) do
    Repo.delete(team_working_time)
  end

  # Team Clocks functions
  def list_team_clocks(team_id) do
    TeamClock
    |> where([c], c.team_id == ^team_id)
    |> Repo.all()
  end

  def get_team_clock!(id), do: Repo.get!(TeamClock, id)

  def create_team_clock(team_id, attrs \\ %{}) do
    %TeamClock{}
    |> TeamClock.changeset(Map.put(attrs, "team_id", team_id))
    |> Repo.insert()
  end

  def update_team_clock(%TeamClock{} = team_clock, attrs) do
    team_clock
    |> TeamClock.changeset(attrs)
    |> Repo.update()
  end

  def delete_team_clock(%TeamClock{} = team_clock) do
    Repo.delete(team_clock)
  end
end
