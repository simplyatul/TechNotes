#! /usr/bin/python
led1 = 21
sleep_time = 5
import RPi.GPIO as GPIO
import time
GPIO.setmode(GPIO.BCM)
GPIO.setup(led1, GPIO.OUT)
while True:
    print("Setting GPIO Pin True")
    GPIO.output(led1, True)
    print("Sleeping for", sleep_time, "sec")
    time.sleep(sleep_time)

    print("Setting GPIO Pin False")
    GPIO.output(led1, False)
    print("Sleeping for", sleep_time, "sec")
    time.sleep(sleep_time)
