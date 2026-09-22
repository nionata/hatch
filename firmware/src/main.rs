#![no_std]
#![no_main]

use esp_backtrace as _;
esp_bootloader_esp_idf::esp_app_desc!();
use esp_hal::{
    delay::Delay,
    rmt::Rmt,
    time::Rate,
};
use esp_hal_smartled::{RmtSmartLeds, WS2812B_TIMING, buffer_size, color_order};
use smart_leds::{SmartLedsWrite, RGB8};

#[esp_hal::main]
fn main() -> ! {
    let peripherals = esp_hal::init(esp_hal::Config::default());
    let delay = Delay::new();

    let freq = Rate::from_mhz(80);
    let rmt = Rmt::new(peripherals.RMT, freq).unwrap();

    // WS2812B on GPIO2. Buffer sized for 1 LED. GRB is the physical wire order.
    let mut led: RmtSmartLeds<{ buffer_size::<RGB8>(1) }, _, RGB8, color_order::Grb> =
        RmtSmartLeds::new(WS2812B_TIMING, rmt.channel0, peripherals.GPIO2, freq).unwrap();

    loop {
        let _ = led.write([RGB8::new(10, 0, 0)].iter().copied()); // dim red
        delay.delay_millis(1000u32);
    }
}
