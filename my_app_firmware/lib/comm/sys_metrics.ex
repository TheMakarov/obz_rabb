defmodule MyAppFirmware.Comm.SystemMetrics do
  defstruct cpu_frequency: nil,
            cpu_usage: nil,
            cpu_temperature: nil,
            memory_usage: %{},
            disk_space: %{},
            network_latency: nil,
            connected_network: []

  @cpu_temp_path "/sys/class/thermal/thermal_zone*/temp"
  @mem_info_path "/proc/meminfo"
  @disk_space_cmd "df"
  @network_latency_cmd ["-c", "1", "google.com"]
  @net_path "/sys/class/net/"
  @cpu_stat_path "/proc/stat"
  @cpu_freq_path "/sys/devices/system/cpu/cpu*/cpufreq/scaling_cur_freq"

  def get_metrics do
    %MyAppFirmware.Comm.SystemMetrics{
      cpu_frequency: fetch_cpu_frequency(),
      cpu_usage: fetch_cpu_usage(),
      cpu_temperature: fetch_cpu_temperature(),
      memory_usage: fetch_memory_usage(),
      disk_space: fetch_disk_space(),
      # network_latency: fetch_network_latency(),
      network_latency: 30,
      connected_network: fetch_connected_network()
    }
  end

  defp fetch_cpu_frequency do
    freq_files =
      Path.wildcard(@cpu_freq_path)
      |> Enum.filter(&File.regular?/1)

    freqs =
      freq_files
      |> Enum.map(&File.read!(&1))
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    case freqs do
      [] ->
        nil

      _ ->
        avg_freq = mean(freqs)
        convert_to_ghz(avg_freq)
    end
  end

  defp convert_to_ghz(khz) do
    # Convert kHz to GHz
    khz / 1_000_000
  end

  defp fetch_cpu_usage do
    {:ok, initial_stats} = read_cpu_stats()
    :timer.sleep(1000)
    {:ok, final_stats} = read_cpu_stats()
    calculate_cpu_usage(initial_stats, final_stats)
  end

  defp read_cpu_stats do
    case File.read(@cpu_stat_path) do
      {:ok, content} ->
        [cpu_line | _] = String.split(content, "\n", trim: true)
        cpu_stats = parse_cpu_line(cpu_line)
        {:ok, cpu_stats}

      {:error, _reason} ->
        {:error, :unable_to_read_cpu_stats}
    end
  end

  defp parse_cpu_line(line) do
    ["cpu" | stats] = String.split(line)

    stats
    |> Enum.map(&String.to_integer/1)
  end

  defp calculate_cpu_usage(initial_stats, final_stats) do
    initial_total = Enum.sum(initial_stats)
    final_total = Enum.sum(final_stats)

    initial_idle = Enum.at(initial_stats, 3) + Enum.at(initial_stats, 4)
    final_idle = Enum.at(final_stats, 3) + Enum.at(final_stats, 4)

    total_diff = final_total - initial_total
    idle_diff = final_idle - initial_idle

    usage = 100 * (total_diff - idle_diff) / total_diff
    usage
  end

  defp fetch_cpu_temperature do
    temp_files =
      Path.wildcard(@cpu_temp_path)
      |> Enum.filter(&File.regular?/1)

    temps =
      temp_files
      |> Enum.map(&File.read!(&1))
      |> Enum.map(&String.trim/1)
      |> Enum.map(&String.to_integer/1)

    case temps do
      [] ->
        nil

      _ ->
        temp = mean(temps)
        temp / 1000
    end
  end

  defp mean([]), do: nil

  defp mean(values) do
    sum = Enum.sum(values)
    length = length(values)
    sum / length
  end

  defp fetch_memory_usage do
    case File.read(@mem_info_path) do
      {:ok, content} ->
        meminfo_lines = String.split(content, "\n")
        total_mem = find_meminfo_value(meminfo_lines, "MemTotal")
        free_mem = find_meminfo_value(meminfo_lines, "MemFree")

        %{total: total_mem, free: free_mem, used: total_mem - free_mem}

      {:error, _} ->
        %{}
    end
  end

  defp find_meminfo_value(lines, key) do
    Enum.find_value(lines, fn line ->
      case String.split(line, ~r/\s*:\s*/) do
        [^key, value] when key in ["MemTotal", "MemFree"] ->
          String.trim(value) |> String.split() |> hd() |> String.to_integer()

        _ ->
          nil
      end
    end)
  end

  defp match_meminfo({:total, value}, :total), do: value
  defp match_meminfo({:free, value}, :free), do: value
  defp match_meminfo(_, _), do: nil

  defp fetch_disk_space do
    case System.cmd(@disk_space_cmd, ["-h"]) do
      {output, 0} ->
        output
        |> String.split("\n", trim: true)
        # Skip header line
        |> Enum.drop(1)
        |> Enum.map(&String.split(&1, ~r/\s+/))
        |> Enum.map(&parse_disk_space_line/1)
        |> Enum.into(%{})

      _ ->
        %{}
    end
  end

  defp parse_disk_space_line([filesystem, size, used, _avail, percent, mount_point]) do
    {filesystem, %{size: size, used: used, percent: percent, mount_point: mount_point}}
  end

  defp fetch_network_latency do
    System.cmd("ping", @network_latency_cmd)
    |> IO.inspect()
    |> case do
      {output, 0} ->
        output
        |> String.split("\n")
        |> List.last()
        |> String.split(" ")
        |> Enum.at(6)

      _ ->
        nil
    end
  end

  defp fetch_connected_network do
    net_devices =
      Path.wildcard(@net_path)
      |> Enum.filter(&File.dir?/1)
      |> Enum.map(&Path.basename/1)

    connected_network =
      Enum.filter(net_devices, fn net_dev ->
        case File.read_link("/sys/class/net/#{net_dev}/operstate") do
          {:ok, "up"} -> true
          _ -> false
        end
      end)

    connected_network
  end
end
