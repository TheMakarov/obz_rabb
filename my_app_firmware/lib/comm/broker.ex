defmodule MyAppFirmware.Comm.Broker do
  use GenServer

  @moduledoc """
  The Main Comm Broker For this solution , all the inter process messages
  passes through it in order to reach the other end;
  it's written to centralize communications across processes
  the state is contains mainly all the info in the system in a giant map structure
  """

  require Logger
  alias MyAppFirmware.Comm.Structs.NervesState, as: State
  alias MyAppFirmware.Comm.Structs.Device, as: Device
  alias MyAppUi.PubSub, as: MainPubSub
  alias Phoenix.PubSub, as: Ps
  alias MyAppFirmware.Comm.DeviceParser
  alias MyAppFirmware.Comm.SystemMetrics
  alias MyAppFirmware.Comm.SystemInfo

  def start_link(_) do
    GenServer.start_link(__MODULE__, %State{}, name: __MODULE__)
  end

  @impl true
  @spec init(_init_arg :: List.t()) :: {:ok, List.t()}
  def init(_init_arg), do: {:ok, %State{}}

  @impl true
  @spec handle_cast({:set_initial_info, State.t()}, Map.t()) :: {:noreply, State.t()}
  @doc """
  this for initializing all the data , it will be used as a last resort !
  """
  def handle_cast({:set_initial_info, payload}, _state) do
    :ok = Ps.broadcast(MainPubSub, "main:0", {:set_initial_info, payload.telemetry})
    {:noreply, payload}
  end

  @impl true
  @spec handle_cast({:update_info, String.t(), Map.t()}, Map.t()) :: {:noreply, State.t()}
  def handle_cast({:update_info, category, payload}, _state) do
    # TO DO  should work on making the state updatable !
    :ok = Ps.broadcast(MainPubSub, "main:0", {:update_info, category, payload})
    {:noreply, payload}
  end

  @impl true
  @spec handle_cast({:add_connected_device, Device.t()}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:add_connected_device, new_device}, state) do
    # TO DO  should work on making the state updatable !
    :ok = Ps.broadcast(MainPubSub, "main:0", {:update_info, "devices", "add", new_device})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:remove_connected_device, String.t()}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:remove_connected_device, new_device_name}, state) do
    # TO DO  should work on making the state updatable !
    :ok = Ps.broadcast(MainPubSub, "main:0", {:update_info, "devices", "remove", new_device_name})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:update_connected_device, Device.t()}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:update_connected_device, new_device}, state) do

    # TO DO  should work on making the state updatable !
    :ok = Ps.broadcast(MainPubSub, "main:0", {:update_info, "devices", "update", new_device})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:probe_dmesg}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:probe_dmesg}, state) do

    # TO DO  should work on making the state updatable !
    {stream, _status} = System.cmd("dmesg", [])
    :ok = Ps.broadcast(MainPubSub, "main:0", {:push_dmesg, stream |> String.split("\n")})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:push_dtop}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:push_dtop}, state) do
    # TO DO  should work on making the state updatable !
    {stream, status} = System.cmd("ps", ["aux"])
    :ok = Ps.broadcast(MainPubSub, "main:0", {:push_dmesg, stream |> String.split("\n")})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:push_wifi_networks}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:push_wifi_networks}, state) do
    # TO DO  should work on making the state updatable !
    Logger.info("scan wifi")
    networks = VintageNetWiFi.quick_scan(2000)

    :ok = Ps.broadcast(MainPubSub, "main:0", {:push_wifi_networks, networks})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:push_wifi_networks}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:connect_wifi_with_ssid_and_password, ssid, password}, state) do
    # TO DO  should work on making the state updatable !
    Logger.info("Connecting wifi")
    success? = VintageNetWiFi.quick_configure(ssid, password)

    :ok = Ps.broadcast(MainPubSub, "main:0", {:push_wifi_network_connected, ssid, success?})
    {:noreply, state}
  end

  @impl true
  # @spec handle_cast({:probe_devices_info, String.t()}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:probe_devices_info, path}, state) do
    # TO DO  should work on making the state updatable !

    info_content = read_device_info(path)
    :ok = Ps.broadcast(MainPubSub, "main:0", {:push_device_info_attributes, info_content})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:probe_devices, String.t()}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:probe_devices}, state) do
    # TO DO  should work on making the state updatable !

    devices = DeviceParser.parse_devices()
    :ok = Ps.broadcast(MainPubSub, "main:0", {:push_devices, devices})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:probe_telemetry, String.t()}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:probe_telemetry}, state) do
    # TO DO  should work on making the state updatable !

    metrics = SystemMetrics.get_metrics()
    :ok = Ps.broadcast(MainPubSub, "main:0", {:push_telemetry, metrics})
    {:noreply, state}
  end

  @impl true
  @spec handle_cast({:probe_uptime}, State.t()) :: {:noreply, State.t()}
  def handle_cast({:probe_uptime}, state) do

    # TO DO  should work on making the state updatable !
    {:ok, uptime} = SystemInfo.get_uptime()
    :ok = Ps.broadcast(MainPubSub, "main:0", {:push_uptime, uptime})
    {:noreply, state}
  end

  defp read_device_info(path) do
    attributes = DeviceParser.read_attributes(path)
    Enum.map_join(attributes, "\n", fn {k, v} -> "#{k}: #{v}" end)
  end
end
