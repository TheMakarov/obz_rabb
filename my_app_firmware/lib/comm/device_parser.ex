defmodule MyAppFirmware.Comm.DeviceParser do
  defmodule Device do
    defstruct [
      :type,
      :path,
      :device_node,
      :attributes
    ]
  end

  @usb_path "/sys/bus/usb/devices/*"
  @cpu_path "/sys/devices/system/cpu/cpu*/cpufreq"
  @camera_path "/sys/class/video4linux/video*"
  @wifi_path "/sys/class/net/wlan*"
  @other_paths ["/sys/class/"]

  def parse_devices do
    devices =
      Enum.concat([
        parse_usb_devices(),
        parse_cpu_devices(),
        parse_camera_devices(),
        parse_wifi_devices(),
        parse_other_devices()
      ])

    # Deduplicate devices based on their path zbal
    devices
    |> Enum.uniq_by(& &1.path)
  end

  defp parse_usb_devices do
    @usb_path
    |> Path.wildcard()
    |> Enum.filter(&File.dir?/1)
    |> Enum.map(&parse_device(&1, "USB"))
  end

  defp parse_cpu_devices do
    @cpu_path
    |> Path.wildcard()
    |> Enum.filter(&File.dir?/1)
    |> Enum.map(&parse_device(&1, "CPU"))
  end

  defp parse_camera_devices do
    @camera_path
    |> Path.wildcard()
    |> Enum.filter(&File.dir?/1)
    |> Enum.map(&parse_device(&1, "Camera"))
  end

  defp parse_wifi_devices do
    @wifi_path
    |> Path.wildcard()
    |> Enum.filter(&File.dir?/1)
    |> Enum.map(&parse_device(&1, "WiFi"))
  end

  defp parse_other_devices do
    @other_paths
    |> Enum.flat_map(&Path.wildcard/1)
    |> Enum.filter(&File.dir?/1)
    |> Enum.map(&parse_device(&1, "Other"))
  end

  defp parse_device(path, type) do
    device_node = find_device_node(path, type)

    %Device{
      type: type,
      path: path,
      device_node: device_node,
      attributes: read_attributes(path)
    }
  end

  defp find_device_node(path, "Camera") do
    # Find the corresponding device node (e.g., /dev/video0)
    case File.ls("/dev") do
      {:ok, dev_files} ->
        dev_files
        |> Enum.filter(&String.starts_with?(&1, "video"))
        |> Enum.find_value(nil, fn file ->
          case File.read_link("/dev/#{file}") do
            {:ok, link_path} ->
              if String.contains?(link_path, path), do: "/dev/#{file}", else: nil

            {:error, _} ->
              nil
          end
        end)

      {:error, _} ->
        nil
    end
  end

  defp find_device_node(_, _), do: nil

  def read_attributes(path) do
    path
    |> Path.join("*")
    |> Path.wildcard()
    |> Enum.filter(&File.regular?/1)
    |> Enum.map(fn file ->
      {Path.basename(file), read_file(file)}
    end)
    |> Enum.into(%{})
  end

  defp read_file(path) do
    case File.read(path) do
      {:ok, content} -> String.trim(content)
      {:error, _} -> nil
    end
  end
end
