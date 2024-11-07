defmodule MyAppUi.Peripherals.Device do
  defstruct name: "dummy_name", type: "Camera?", path: "/dev/zab", state: %{}, alive?: true

  def changeset(struct, _attr \\ %{}) do
    struct
  end
end
