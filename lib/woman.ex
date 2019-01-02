defmodule Bar.Woman do
  @spec enter(pid) :: :ok
  def enter(bar) do
	Bar.enter bar, :woman
  end
end
