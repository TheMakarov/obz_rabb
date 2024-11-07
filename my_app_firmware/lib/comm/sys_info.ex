defmodule MyAppFirmware.Comm.SystemInfo do

  def get_uptime do
    case File.read("/proc/uptime") do
      {:ok, content} ->
        [uptime_seconds | _] = String.split(content)
        {:ok, String.to_float(uptime_seconds)}
      {:error, reason} ->
        {:error, reason}
    end
  end
end
