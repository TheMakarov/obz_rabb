defmodule MyAppFirmware.Comm.Structs.Device do
  defstruct name: nil,
            path: nil,
            up_time: nil,
            health: nil,
            logs_text: nil,
            api_conf: %{
              url: nil,
              port: nil
            }
end
