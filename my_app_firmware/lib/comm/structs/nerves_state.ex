defmodule MyAppFirmware.Comm.Structs.NervesState do
  defstruct telemetry: %{},
            connected_devices: %{},
            wifi_status: %{},
            system_additional_info: %{},
            other: %{}
end
