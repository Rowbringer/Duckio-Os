#![no_std]
#![no_main]

use core::fmt::{self, Write};
use core::panic::PanicInfo;
use limine::framebuffer::FramebufferRequest;

#[used]
static FRAMEBUFFER_REQUEST: FramebufferRequest = FramebufferRequest::new();

struct FbWriter {
    buffer: *mut u8,
    pitch: usize,
    width: usize,
    height: usize,
    x: usize,
    y: usize,
    color: u32,
}

impl FbWriter {
    fn new(buffer: *mut u8, pitch: usize, width: usize, height: usize) -> Self {
        Self { buffer, pitch, width, height, x: 16, y: 16, color: 0x00D9D9D9 }
    }

    fn clear(&mut self, color: u32) {
        for yy in 0..self.height {
            for xx in 0..self.width {
                self.put_pixel(xx, yy, color);
            }
        }
    }

    fn put_pixel(&mut self, x: usize, y: usize, color: u32) {
        let offset = y * self.pitch + x * 4;
        unsafe { (self.buffer.add(offset) as *mut u32).write_volatile(color) }
    }

    fn put_char(&mut self, c: char) {
        if c == '\n' {
            self.x = 16;
            self.y += 18;
            return;
        }
        for row in 0..14 {
            for col in 0..8 {
                let on = ((c as u8).wrapping_add(row as u8).wrapping_add(col as u8) & 1) == 0;
                if on {
                    self.put_pixel(self.x + col, self.y + row, self.color);
                }
            }
        }
        self.x += 9;
    }
}

impl Write for FbWriter {
    fn write_str(&mut self, s: &str) -> fmt::Result {
        for c in s.chars() {
            self.put_char(c);
        }
        Ok(())
    }
}

#[no_mangle]
pub extern "C" fn _start() -> ! {
    let response = FRAMEBUFFER_REQUEST.get_response().get().expect("no fb");
    let fb = response.framebuffers().next().expect("no framebuffer");

    let mut writer = FbWriter::new(
        fb.addr().as_ptr().cast::<u8>(),
        fb.pitch() as usize,
        fb.width() as usize,
        fb.height() as usize,
    );
    writer.clear(0x0014181f);
    let _ = writeln!(writer, "Duckio OS");
    let _ = writeln!(writer, "Real OS prototype booted on bare metal.");
    let _ = writeln!(writer, "Next step: scheduler + drivers + filesystem.");

    loop { core::hint::spin_loop(); }
}

#[panic_handler]
fn panic(_info: &PanicInfo) -> ! {
    loop { core::hint::spin_loop(); }
}
