from sys import platform

import serial


class Turk:
    def __init__(self, port=None, baudrate=9600, timeout=0.5, write_timeout=0.5, **kwargs):
        if port is None:
            if platform == "linux" or platform == "linux2":
                port = "/dev/socatpty3"
            elif platform == "win32":
                port = "COM20"
        self._serial = serial.Serial(port=port, baudrate=baudrate, timeout=timeout, write_timeout=write_timeout,
                                     parity=serial.PARITY_NONE,
                                     stopbits=serial.STOPBITS_ONE,
                                     bytesize=serial.EIGHTBITS,
                                     xonxoff=False,
                                     rtscts=False,
                                     dsrdtr=False, **kwargs)
        # Enter write mode in Cisco IOS (press enter a couple of times)
        self._serial.write(b'\r\n'*5)
        self._serial.flush()

    def _send_command(self, command):
        try:
            message = f"{command}\r\n"
            self._serial.write(message.encode())
            self._serial.flush()
            # Skip the first line (echo) and messages other sockets
            while True:
                data = self._serial.readline()
                if command.encode() in data:
                    break

            while True:
                data = self._serial.readline().decode()
                print(data, end='')
                # Handle incomplete output
                if "--More--" in data:
                    self._serial.write(b' ')
                    self._serial.flush()
                    continue
                # Check if no more data is available within the timeout
                if not data:
                    break
            # If a command with "?" is used, clear the prompt with backspaces
            if "?" in message:
                self._serial.write(('\010' * (len(message) - 1)).encode())
                self._serial.flush()
        except serial.SerialException:
            print("Error writing to serial port")

    def __call__(self, *args):
        if len(args) == 1:
            self._send_command(args[0])
        else:
            for i, arg in enumerate(args):
                self._send_command(arg)
                if i != len(args) - 1:
                    print("\n")