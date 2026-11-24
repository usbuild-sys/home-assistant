# Optolink P300 register scanner. Stop optolink2mqtt first (it holds the port).
import serial, time
P="/dev/serial/by-id/usb-Silicon_Labs_CP2102_USB_to_UART_Bridge_Controller_0001-if00-port0"
s=serial.Serial(P,4800,bytesize=8,parity='E',stopbits=2,timeout=2)
s.write(b'\x04');time.sleep(0.5);s.reset_input_buffer()
for _ in range(10):
    if s.read(1)==b'\x05': s.write(b'\x16\x00\x00');break
print("init",s.read(1).hex())
def rd(a,n):
    b=bytes([5,0,1,a>>8,a&255,n]);s.write(b'\x41'+b+bytes([sum(b)&255]))
    r=s.read(9+n);return r[8:8+n].hex() if len(r)==9+n and r[0]==6 and r[3]==1 else "ERR "+r.hex()
L=[("mode",0x2323,1),("cur_mode",0x2500,1),("burner",0x55D3,1),("modulation",0xA38F,2),("fault",0x0A82,1),("hc_pump",0x2906,1),("int_pump",0x7660,1),
 ("flue",0x0816,2),("common_flow",0x081A,2),("flow_set",0x2544,2),("burn_hours",0x08A7,4),("burn_starts",0x088A,4),("slope",0x27D3,1),("level",0x27D4,1)]
for name,a,n in L:
    print(f"{name:11s} {a:#06x} {rd(a,n)}")
s.close()
