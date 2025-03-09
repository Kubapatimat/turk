# Turk
A toolkit for carrying out Computer Networks labs in a more manageable way.

## Installation
### Windows with GNS3
```shell
python -m venv venv
.\venv\Scripts\activate
pip install -r requirements.txt
```

Install `com0com` from [here](https://sourceforge.net/projects/com0com/) to get the virtual COM drivers.
You should have two following pair of virtual COM ports by default when running the *Setup* tool: `CNCA0 <--> CNCB0`.

Next, change the `CNCA0` port name to `COMXX`, where `XX` is an unused number, for example `COM20`. You can do
this automatically by running the following command in the `com0com` installation directory:
```shell
cd "C:\Program Files (x86)\com0com"
setupc change CNCA0 PortName=COM20
```

If you changed the port name to something different, you should also change the COM port in the Jupyter Notebook.

Run the GNS3 software and start a device (e.g. Cisco c7200) on TCP port `5000`. You can open the Solar-PuTTY console
by double-clicking on the device or use a separate instance of PuTTY (use the `telnet` protocol) to connect.

Next, bridge the virtual COM port with the TCP port of the device. You can do this by running:

`proxy.bat --connection tcp`.

### Windows with real device (lab setup)

Connect the device to the computer via the USB-to-serial adapter. You can find the COM port number in the
Device Manager. As an example, let's assume that the COM port number is `COM3`. As the jupyter notebook is not meant to
be a complete solution to finish the labs, you will also need a terminal to type the rest of the commands yourself.
As only one device can use a single COM port at any given time, we need to create a virtual port hub.

We will use a total of 3 COM ports:
- `COM20 <--> CNCB0` - Jupyter Notebook,
- `COM21 <--> CNCB1` - PuTTY,
- `COM3 <--> CNCB2` - device, e.g. Cisco router.

You can create the virtual COM ports by running the following command in the `com0com` installation directory:
```shell
cd "C:\Program Files (x86)\com0com"
setupc remove 0
setupc remove 1
setupc remove 2
setupc install PortName=COM20 PortName=CNCB0
setupc install PortName=COM21 PortName=CNCB1
setupc install PortName=COM3 PortName=CNCB2
```

To test the connection (without having access to the physical device) you can do the following:
1. Run `proxy.bat --connection serial`.
2. Run `python .\test\mock_device.py`.
3. Connect to the device using PuTTY on the `COM21` port.
4. Open the jupyter notebook and connect to the device using the `COM20` port.
5. Test commands by running `t("help")` in the notebook.

In the lab, you would normally only do steps 1, 3, and 4.

### Linux with GNS3
1. Install `socat` package.
2. Add yourself to the `dialout` group: `sudo usermod -a -G dialout $USER`.
3. Log out and log back in to apply the changes.
4. Run:
```shell
sudo ./proxy.sh --connection=tcp
```
Sudo is needed because of modifying filed in `/dev/`. If you don't want to use sudo, you can use
device files in another location, e.g. `$HOME/socatpty1`.
5. Run PuTTY Serial on `/socatpty2`.
6. Open Jupyter Notebook and set the port to `/socatpty3` (or leave it as it).

### Linux with real device (lab setup)
1. Install `socat` package.
2. Add yourself to the `dialout` group: `sudo usermod -a -G dialout $USER`.
3. Log out and log back in to apply the changes.
4. If running test connection, type:
```shell
sudo ./proxy.sh --connection=serial
```
If you are using a real device, e.g. `/dev/ttyUSB0`, type:
```shell
sudo ./proxy.sh --connection=serial --port="/dev/ttyUSB0"
```
Sudo is needed because of modifying filed in `/dev/`. If you don't want to use sudo, you can use
device files in another location, e.g. `$HOME/socatpty1`.
5. To test the connection, use:
```shell
python test/mock_device.py
```
6. Run PuTTY Serial on `/socatpty2`.
7. Open Jupyter Notebook and set the port to `/socatpty3` (or leave it as it).

## Usage

Open the Jupyter Notebook by running the following command:
```shell
jupyter notebook
```

If necessary, change the port:
```python
from turk import Turk
t = Turk(port="COMXX")
```

If `port=None`, it will automatically assign the ports mentoned in this file based on the operating system.

Have fun speedrunning the labs!

## Troubleshooting
- If the COM port is in use (`SerialException: could not open port 'COM20': PermissionError(13, 'Odmowa dostępu.', None, 5)`),
restart the python kernel in the Jupyter Notebook.