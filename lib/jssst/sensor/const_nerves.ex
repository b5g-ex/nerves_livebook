defmodule Jssst.Sensor.ConstNerves do
  @moduledoc """
  定数を定義するためのモジュール
  """

  def i2c_bus(), do: i2c_bus_rpi()
  def i2c_addr(), do: i2c_addr_aht20()
  def i2c_delay_ms(), do: 100
  def i2c_2pow20(), do: 1048576   # 2^20

  def i2c_bus_rpi(), do: "i2c-1"
  def i2c_bus_bbb(), do: "i2c-2"
  def i2c_addr_mcp9808(), do: 0x18
  def i2c_addr_aht20(), do: 0x38
  def i2c_addr_ina226(), do: 0x41 # can be assigned 0x40 to 0x4f (no default)
end
