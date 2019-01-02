defmodule Bar do
  @moduledoc """
  Simulate a pub with the rule that every man must wait for two women to enter 
  """

  use GenServer

  defstruct men: 0, women: 0, men_queue: :queue.new()

  @type gender :: :man | :woman
  @typep queue(t) :: {[t], [t]}
  @type state :: %__MODULE__{
          men: non_neg_integer,
          women: non_neg_integer,
          men_queue: queue(identifier())
        }

  ### API

  def start_link(opts \\ []) do
    GenServer.start_link(__MODULE__, :ok, opts)
  end

  @spec enter(identifier(), gender()) :: :enter | :wait
  def enter(bar, :man) do
    GenServer.call(bar, :man)
  end

  def enter(bar, :woman) do
	GenServer.cast(bar, :woman)
  end

  ### GenServer callbacks

  @impl true
  def init(:ok) do
    {:ok, %__MODULE__{}}
  end

  @impl true
  def handle_call(:debug, _from, state), do: {:reply, state, state}

  def handle_call(:man, _from, state = %__MODULE__{women: women}) when women >= 2 do
    {:reply, :enter, %{state | women: women - 2}}
  end

  def handle_call(:man, {pid, _}, state = %__MODULE__{men: men, men_queue: queue}) do
    {:reply, :wait, %{state | men: men + 1, men_queue: :queue.in(pid, queue)}}
  end

  @impl true
  def handle_cast(:woman, state = %__MODULE__{men: 0, women: women}) do
    {:noreply, %{state | women: women + 1}}
  end

  def handle_cast(:woman, state = %__MODULE__{women: 0}) do
    {:noreply, %{state | women: 1}}
  end

  def handle_cast(:woman, state = %__MODULE__{men: men, women: women, men_queue: queue})
      when men >= 1 and women >= 1 do
    {{:value, man}, rest} = :queue.out(queue)
    send(man, :enter)
    {:noreply, %{state | men: men - 1, women: women - 1, men_queue: rest}}
  end
end
