defmodule Jssst.Sensor.Aht20 do
  @moduledoc """
  Documentation for `Aht20`.
  温湿度センサAHT20の制御モジュール
  """

  # 関連するライブラリを読み込み
  require Logger
  use Bitwise
  alias Circuits.I2C

  # 定数
  alias Jssst.Sensor.ConstNerves
  @i2c_bus ConstNerves.i2c_bus
  @i2c_addr ConstNerves.i2c_addr
  @i2c_delay ConstNerves.i2c_delay_ms
  @two_pow_20 ConstNerves.i2c_2pow20

  @doc """
  温度を表示
  ## Examples
    iex> Sensor.Aht20.print_temp
    > temp (degree Celsius)
    22.1
    :ok
  """
  def print_temp() do
    IO.puts(" > temp: #{temp()} (degree Celsius)")
  end

  # 温度の値を取得
  defp temp() do
    # AHT20から読み出し
    {:ok, {temp, _}} = read_from_aht20()
    temp
  end

  @doc """
  湿度を表示
  ## Examples
    iex> Sensor.Aht20.print_humi
    > humi (%)
    41.2
    :ok
  """
  def print_humi() do
    IO.puts(" > humi: #{humi()} (%)")
  end

  # 湿度の値を取得
  defp humi() do
    # AHT20から読み出し
    {:ok, {_, humi}} = read_from_aht20()
    humi
  end

  @doc """
  AHT20から温度・湿度を取得
  ## Examples
    iex> Sensor.Aht20.read_from_aht20
    {:ok, {22.4, 40.3}}
    {:error, "Sensor is not connected"}
  """
  def read_from_aht20() do
    # I2Cを開く
    {:ok, ref} = I2C.open(@i2c_bus)

    # AHT20を初期化する
    I2C.write(ref, @i2c_addr, <<0xBE, 0x08, 0x00>>)
    # 処理完了まで一定時間待機
    Process.sleep(@i2c_delay)

    # 温度・湿度を読み出しコマンドを送る
    I2C.write(ref, @i2c_addr, <<0xAC, 0x33, 0x00>>)
    # 処理完了まで一定時間待機
    Process.sleep(@i2c_delay)

    # 温度・湿度を読み出す
    ret =
      case I2C.read(ref, @i2c_addr, 7) do
        # 正常に値が取得できたときは温度・湿度の値をタプルで返す
        {:ok, val} -> {:ok, val |> convert()}
        # センサからの応答がないときはメッセージを返す
        {:error, :i2c_nak} -> {:error, "Sensor is not connected"}
        # その他のエラーのときもメッセージを返す
        _ -> {:error, "Unexpected error occurred"}
      end

    # I2Cを閉じる
    I2C.close(ref)

    # 結果を返す
    ret
  end

  # 生データを温度と湿度の値に変換
  ## Parameters
  ## - val: POSTする内容
  defp convert(src) do
    # バイナリデータ部をビット長でパターンマッチ
    # <<0:state, 1:humi1, 2:humi2, 3:humi3/temp1, 4:temp2, 5:temp3, 6:crc>>
    <<_state::8, raw_humi::20, raw_temp::20, _crc::8>> = src

    # 湿度に換算する計算（データシートの換算方法に準じた）
    humi = Float.round(raw_humi / @two_pow_20 * 100.0, 1)

    # 温度に換算する計算（データシートの換算方法に準じた）
    temp = Float.round(raw_temp / @two_pow_20 * 200.0 - 50.0, 1)

    # 温度と湿度をタプルにして返す
    {temp, humi}
  end
end
