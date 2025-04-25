import RPi.GPIO as gpio
from time import sleep
import os
import subprocess

SHUTDOWN_PIN = 26

user = os.environ.get("SUDO_USER") or os.environ.get("USER") or os.listdir('/home')[0]

gcode_console = os.path.join('/home', user, 'printer_data', 'comms', 'klippy.serial')


def run_gcode(command):
    with open(gcode_console, 'a') as console:
        console.write(command + '\n')

def shutdown_printer(channel):
    for _ in range(50):
        if gpio.input(SHUTDOWN_PIN) == gpio.HIGH:
            return
        sleep(0.01)
    run_gcode("_SHUTDOWN")
    sleep(120)
    subprocess.run(["shutdown", "-h", "now"])
    sleep(120)


gpio.setmode(gpio.BCM)
gpio.setup(SHUTDOWN_PIN, gpio.IN)

sleep(1)

gpio.add_event_detect(SHUTDOWN_PIN, gpio.FALLING)
gpio.add_event_callback(SHUTDOWN_PIN, shutdown_printer)

while True:
    sleep(60)
