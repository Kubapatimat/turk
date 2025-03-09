import serial
import time
import logging
from sys import platform


logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

DEVICE_COMMANDS = {
    "help": "available commands: help, version, show ip interface brief",
    "version": "1.2.3",
    "show ip interface brief": """
Interface              IP-Address      OK? Method Status                Protocol
FastEthernet0/0        unassigned      YES NVRAM  up                    up 
"""
}


def simulate_device(port='COM3', baudrate=9600, timeout=0.5, write_timeout=0.5, **kwargs):
    try:
        ser = serial.Serial(
            port=port, baudrate=baudrate, timeout=timeout, write_timeout=write_timeout,
            xonxoff=False, rtscts=False, dsrdtr=False, **kwargs
        )
    except serial.SerialException as e:
        logger.error(f"Error opening serial port: {e}")
        return

    logger.info(f"Mock device listening on {port} at {baudrate} baud...\n")

    while True:
        command_buffer = ""
        while True:
            byte = ser.read(1)
            if byte:
                char = byte.decode('utf-8', errors='ignore')

                try:
                    ser.write(byte)
                except serial.SerialException as e:
                    logger.error(f"Write error: {e}")
                    ser.close()
                    time.sleep(1)
                    ser.open()
                    continue

                if char in ['\r', '\n']:
                    if command_buffer.strip():
                        logger.info(f"Received command: {command_buffer.strip()}")
                        response = DEVICE_COMMANDS.get(command_buffer.strip(), "Invalid command. Type 'help' for available options.")
                        try:
                            ser.write(b'\r\n' + response.encode() + b'\r\n')
                        except serial.SerialException as e:
                            logger.error(f"Write error while sending response: {e}")
                    command_buffer = ""
                else:
                    command_buffer += char


if __name__ == "__main__":
    serial_port = None
    if platform == "linux" or platform == "linux2":
        serial_port = "/dev/socatpty1"
    elif platform == "win32":
        serial_port = "COM3"
    simulate_device(port=serial_port)
