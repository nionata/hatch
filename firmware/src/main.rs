#![no_std]
#![no_main]

use esp_backtrace as _;
esp_bootloader_esp_idf::esp_app_desc!();
use esp_hal::{delay::Delay, rmt::Rmt, time::Rate};
use esp_hal_smartled::{buffer_size, color_order, RmtSmartLeds, WS2811_LOW_SPEED_TIMING};
use smart_leds::{SmartLedsWrite, RGB8};

const NUM_LEDS: usize = 50; // adjust to match your strip length

#[esp_hal::main]
fn main() -> ! {
    let peripherals = esp_hal::init(esp_hal::Config::default());
    let delay = Delay::new();

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();

    // WS2811 on GPIO4. RGB color order. Drive all LEDs to clear the power-on state.
    let mut led: RmtSmartLeds<{ buffer_size::<RGB8>(NUM_LEDS) }, _, RGB8, color_order::Rgb> =
        RmtSmartLeds::new(
            WS2811_LOW_SPEED_TIMING,
            rmt.channel0,
            peripherals.GPIO4,
            freq,
        )
        .unwrap();

    loop {
        let mut colors = [RGB8::default(); NUM_LEDS];
        colors[0] = RGB8::new(10, 0, 0);
        let _ = led.write(colors.iter().copied());
        delay.delay_millis(1000u32);
    }
}
