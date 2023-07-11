defmodule DancingDots.Dot do
  defstruct [:x, :y, :radius, :opacity]

  @type t :: %__MODULE__{}
end

defmodule DancingDots.Animation do
  @type dot :: DancingDots.Dot.t()
  @type opts :: keyword
  @type error :: any
  @type frame_number :: pos_integer

  @callback init(opts()) :: {:ok, opts()} | {:error, error()}
  @callback handle_frame(dot(), frame_number(), opts()) :: dot()

  defmacro __using__(_) do
    quote do
      @behaviour DancingDots.Animation

      @impl DancingDots.Animation
      def init(opts), do: {:ok, opts}

      defoverridable init: 1
    end
  end
end

defmodule DancingDots.Flicker do
  use DancingDots.Animation

  @impl DancingDots.Animation
  def handle_frame(dot, frame_number, _) when rem(frame_number, 4) != 0, do: dot

  @impl DancingDots.Animation
  def handle_frame(%DancingDots.Dot{opacity: o} = dot, _, _), do: %{dot | opacity: o / 2}
end

defmodule DancingDots.Zoom do
  use DancingDots.Animation

  @impl DancingDots.Animation
  def init(opts) do
    case Keyword.get(opts, :velocity) do
      v when is_number(v) ->
        {:ok, opts}

      v ->
        {:error,
         "The :velocity option is required, and its value must be a number. Got: #{inspect(v)}"}
    end
  end

  @impl DancingDots.Animation
  def handle_frame(dot, frame_number, opts) do
    case init(opts) do
      {:ok, opts} ->
        %DancingDots.Dot{radius: r} = dot
        v = Keyword.get(opts, :velocity)
        %{dot | radius: r + (frame_number - 1) * v}

      err ->
        err
    end
  end
end
