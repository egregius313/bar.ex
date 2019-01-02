defmodule Bar.Man do
  @spec enter(pid) :: :ok
  def enter(bar) do
    case Bar.enter(bar, :man) do
      :enter ->
        :ok

      :wait ->
        receive do
          :enter ->
            :ok
        end
    end
  end
end
