defmodule MyAppUiWeb.DashboardLive do
  use MyAppUiWeb, :live_view
  alias MyAppUi.Peripherals.Device
  alias MyAppUi.PubSub, as: MainPubSub
  alias Phoenix.PubSub, as: Ps
  require Logger

  @image_dir "assets/saves"

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      Process.send_after(self(), :schedule, 2000)
      :ok = Ps.subscribe(MainPubSub, "main:0")
    end

    socket =
      initial_assigns(socket)

    {:ok, socket}
  end

  @impl true
  def handle_event("phx_live_view:mount", _payload, socket) do
    {:noreply, socket}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :home, _something) do
    socket
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Device")
    |> assign(:device, %Device{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Devices")
    |> assign(:device, nil)
  end

  @impl true
  def handle_info({:set_initial_info, payload}, socket) do
    Logger.debug("just setted inital info ")

    socket =
      socket
      |> assign(:temp, Map.get(payload, :temp, "0C"))
      |> assign(:memory, Map.get(payload, :memory, "0B"))
      |> assign(:network_latency, Map.get(payload, :network_latency, "0"))
      |> assign(:network_name, Map.get(payload, :network_name, "not set"))
      |> assign(:disk_usage, Map.get(payload, :disk_usage, "not set"))

    {:noreply, socket}
  end

  def handle_info({:push_telemetry, metrics}, socket) do
    Logger.debug("just updated inital info ")

    list_disks_usages =
      Map.get(metrics, :disk_space)
      |> Enum.map(& &1)

    cpu_usage =
      Map.get(metrics, :cpu_usage)
      |> Float.floor(2)

    cpu_frequency =
      Map.get(metrics, :cpu_frequency)
      |> Float.floor(2)

    socket =
      socket
      |> assign(:temp, Map.get(metrics, :cpu_temperature))
      |> assign(:memory, Map.get(metrics, :memory_usage))
      |> assign(:network_latency, Map.get(metrics, :network_latency))
      |> assign(:network_name, Map.get(metrics, :connect_network, "not set"))
      |> assign(:disk_usage, list_disks_usages)
      |> assign(:cpu_usage, cpu_usage)
      |> assign(:cpu_frequency, cpu_frequency)

    {:noreply, socket}
  end

  def handle_info({:update_info, "devices", op, new_device}, socket) do
    do_apply(op, new_device, socket)
  end

  defp do_apply("add", new_device, socket) do
    devices =
      socket.assigns.devices

    if Enum.find(devices, &(&1.name == new_device.name)) do
      Logger.debug("device already exists ")
      {:noreply, socket}
    else
      Logger.debug("adding device with #{new_device.name}")
      devices = Enum.concat(devices, [new_device])
      {:noreply, socket |> assign(:devices, devices)}
    end
  end

  defp do_apply("remove", new_device_name, socket) do
    devices =
      socket.assigns.devices
      |> Enum.reject(&(&1.name == new_device_name))

    {:noreply, socket |> assign(:devices, devices)}
  end

  defp do_apply("update", new_device, socket) do
    device_index =
      socket.assigns.devices
      |> Enum.find_index(&(&1.name == new_device.name))

    devices =
      socket.assigns.devices
      |> List.insert_at(device_index, new_device)

    {:noreply, socket |> assign(:devices, devices)}
  end

  def handle_info({:push_dmesg, stream}, socket) do
    {:noreply, socket |> assign(:dmesg_stream, stream)}
  end

  def handle_info({:push_uptime, uptime}, socket) do
    {:noreply, socket |> assign(:uptime, uptime)}
  end

  def handle_info({:push_wifi_networks, networks}, socket) do
    {:noreply, socket |> assign(:networks, networks)}
  end

  def handle_info({:push_wifi_network_connected, ssid, success?}, socket) do
    case success? do
      :ok ->
        socket =
          socket
          |> put_flash(:info, "connected to #{ssid}")

        {:noreply, socket}

      _ ->
        socket =
          socket
          |> put_flash(:error, "couldn't connect to #{ssid}")

        {:noreply, socket}
    end
  end

  defp initial_assigns(socket) do
    devices = [
      %{
        type: "audio Array",
        path: "/dev/udev/1",
        up_time: "10hrs",
        health: "NOT SO GREAT",
        logs_text: "EMPTY FOR NOW",
        api_conf: %{
          url: "/asdasd",
          port: "123123"
        },
        device_node: nil
      },
      %{
        api_conf: %{
          port: "5001",
          url: "http://localhost:5001/audio"
        },
        health: "Good",
        logs_text: "EMPTY FOR NOW",
        type: "Audio Array",
        path: "/dev/audio1",
        up_time: "24h",
        device_node: nil
      },
      %{
        api_conf: %{
          port: "5002",
          url: "http://localhost:5002/temp"
        },
        health: "Good",
        logs_text: "EMPTY FOR NOW",
        type: "Temperature Sensor",
        path: "/dev/tempsensor",
        up_time: "24h",
        device_node: nil
      }
    ]

    socket
    |> assign(:temp, "40C")
    |> assign(:memory, %{free: 1, total: 144, used: 144})
    |> assign(:network_latency, 22)
    |> assign(:network_name, "makarov_the_great")
    |> assign(:disk_usage, [
      {
        "/dev/test",
        %{
          size: "18.7M",
          used: "15.7M",
          percent: "84%",
          mount_point: "/test"
        }
      }
    ])
    |> assign(:devices, devices)
    |> assign(:images, [])
    # |> assign(:images, list_images())
    |> assign(:selected_image, nil)
    |> assign(:show_popup, false)
    |> assign(:dmesg_stream, ["Nothing for now "])
    |> assign(:modal_open, false)
    |> assign(:current_network, nil)
    |> assign(:form, %{})
    |> assign(:selected_tab, "telemetry")
    |> assign(:show_info, false)
    |> assign(:info_content, "Nada")
    |> assign(:cpu_usage, 100)
    |> assign(:cpu_frequency, 2.00)
    |> assign(:networks, [
      %{ssid: "Network1", channel: 11, signal_dbm: -50, flags: [:wpa2_psk]}
    ])
    |> assign(:uptime, 0)
    |> assign(:refreshed, false)
  end

  def trying(selected_tab, target_tab) do
    selected_tab == target_tab
  end

  def handle_event("select_image", %{"image" => image}, socket) do
    IO.inspect(image, label: "this is image")
    {:noreply, assign(socket, selected_image: image, show_popup: true)}
  end

  def handle_event("close_popup", _params, socket) do
    {:noreply, assign(socket, show_popup: false)}
  end

  def handle_event("select_tab", %{"tab" => selected_tab}, socket) do
    IO.puts("Received custom event with data: #{selected_tab}")
    {:noreply, socket |> assign(:selected_tab, selected_tab)}
  end

  def handle_event(
        "upload_image",
        %{"image" => %Plug.Upload{path: path, filename: filename}},
        socket
      ) do
    File.cp(path, Path.join(@image_dir, filename))
    {:noreply, assign(socket, images: list_images())}
  end

  def handle_event("connect", %{"ssid" => ssid}, socket) do
    socket =
      assign(socket, modal_open: true, current_network: ssid, form: %{"security" => "WPA2"})

    {:noreply, socket |> push_event("show_modal", %{id: "modal"})}
  end

  def handle_event("validate", %{"form" => form_params}, socket) do
    changeset = validate_form(form_params)
    {:noreply, assign(socket, form: form_params, changeset: changeset)}
  end

  @impl true
  def handle_event("submit", %{"form" => %{"password" => password, "ssid" => ssid}}, socket) do
    :ok =
      GenServer.cast(
        MyAppFirmware.Comm.Broker,
        {:connect_wifi_with_ssid_and_password, ssid, password}
      )

    # changeset = validate_form(form_params)

    # if changeset.valid? do
    #   IO.puts("Connecting to #{form_params["ssid"]} with #{inspect(form_params)}")

    #   {:noreply, assign(socket, modal_open: false) |> push_event("hide_modal", %{id: "modal"})}
    # else
    #   {:noreply, assign(socket, changeset: changeset)}
    # end
    {:noreply, socket}
  end

  def handle_event("show_info", %{"ssid" => ssid}, socket) do
    IO.puts("Showing info for #{ssid}...")
    {:noreply, socket}
  end

  @impl true
  def handle_info({:push, :temp, value}, socket) do
    {
      :noreply,
      socket
      |> assign(:temp, value)
    }
  end

  def handle_event("show_info", %{"path" => path}, socket) do
    Logger.info "called from the front now ! "
    :ok = GenServer.cast(MyAppFirmware.Comm.Broker, {:probe_devices_info, path})
    {:noreply, assign(socket, show_info: true, info_content: nil)}
  end

  def handle_info({:push_device_info_attributes, info_content}, socket) do
    {:noreply, assign(socket, show_info: true, info_content: info_content)}
  end

  def handle_info({:push_devices, devices}, socket) do
    {:noreply, assign(socket, devices: devices)}
  end

  def handle_event("connect", %{"path" => _path}, socket) do
    # Implement your connection logic here
    {:noreply, socket}
  end

  def handle_event("close_modal", _params, socket) do
    {:noreply, assign(socket, show_info: false, info_content: nil)}
  end

  defp list_images do
    @image_dir
    |> File.ls!()
    |> Enum.map(&Path.join(@image_dir, &1))
  end

  defp validate_form(form_params) do
    # Perform validation on form_params, return a changeset
    # For simplicity, let's assume the form is always valid
    %{valid?: true}
  end

  def handle_event("refresh_wifis", _,  socket) do
    :ok = GenServer.cast(MyAppFirmware.Comm.Broker, {:push_wifi_networks})

    {:noreply, assign(socket, refreshed: true)}
  end

  def handle_info(:schedule, socket) do
    Process.send_after(self(), :schedule, 1000)
    :ok = GenServer.cast(MyAppFirmware.Comm.Broker, {:probe_devices})
    :ok = GenServer.cast(MyAppFirmware.Comm.Broker, {:probe_telemetry})
    :ok = GenServer.cast(MyAppFirmware.Comm.Broker, {:probe_dmesg})
    :ok = GenServer.cast(MyAppFirmware.Comm.Broker, {:probe_uptime})
    {:noreply, socket}
  end
end
