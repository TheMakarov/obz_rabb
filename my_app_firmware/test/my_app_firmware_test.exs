defmodule MyAppFirmwareTest do
  use ExUnit.Case
  doctest MyAppFirmware

  test "greets the world" do
    assert MyAppFirmware.hello() == :world
  end
end
