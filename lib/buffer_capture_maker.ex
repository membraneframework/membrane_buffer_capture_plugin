defmodule Membrane.BufferCapture.CaptureMaker do
  use Membrane.Sink

  def_options location: [type: :string, description: "Path to save location"]

  def_input_pad :input, demand_unit: :buffers, caps: :any

  @impl true
  def handle_init(options), do: {:ok, %{buffers: [], location: options.location}}

  @impl true
  def handle_caps(:input, _caps, _context, state) do
    {:ok, state}
  end

  @impl true
  def handle_prepared_to_playing(_ctx, state) do
    {{:ok, demand: :input}, state}
  end

  @impl true
  def handle_write(:input, buffer, _ctx, state) do
    {{:ok, demand: :input}, %{state | buffers: [buffer | state.buffers]}}
  end

  @impl true
  def handle_end_of_stream(:input, _ctx, state) do
    {:ok, file} = File.open(state.location, [:write])
    capture = Enum.reverse(state.buffers) |> :erlang.term_to_binary()
    IO.binwrite(file, capture)

    {:ok, state}
  end
end
