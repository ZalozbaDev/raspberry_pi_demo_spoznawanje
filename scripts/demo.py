#!/usr/bin/python3 -u
# -*- coding:utf-8 -*-

import RPi.GPIO as GPIO
import time
import os
import subprocess
import re

import apa102

KEY = [6]
LED = [26,12,16]

POWER = 5

PIXELS_N = 12

ring = apa102.APA102(num_led=PIXELS_N)

GPIO.setmode(GPIO.BCM)

for i in KEY:
    print("Setting up GPIO " + str(i) + " to input/pullup.")
    GPIO.setup(i, GPIO.IN, GPIO.PUD_UP)

#define a easy way to set pin value
def ledWrite(pin,value):
        if value:
                GPIO.output(pin,GPIO.HIGH)
        else:
                GPIO.output(pin,GPIO.LOW)

def ringWrite(data):
        for i in range(PIXELS_N):
            ring.set_pixel(i, int(data[4*i + 1]), int(data[4*i + 2]), int(data[4*i + 3]))
        ring.show()
	

for i in LED:
        GPIO.setup(i,GPIO.OUT)
        print("Setting up LED " + str(i) + " to OFF.")
        ledWrite(i,0)
        
# enable ring power
GPIO.setup(POWER, GPIO.OUT)
GPIO.output(POWER, GPIO.HIGH)

outLED = GPIO.PWM(16,50)
outLED.start(0)
outLED.ChangeDutyCycle(0)
statusLED = GPIO.PWM(26,50)
statusLED.start(0)
statusLED.ChangeDutyCycle(0)

while True:
    time.sleep(0.05)
    statusLED.ChangeDutyCycle(50)
    if GPIO.input(KEY[0]) == 0:
        print("Button " + str(0) + " is pressed.")
        statusLED.ChangeDutyCycle(0)
        process = subprocess.Popen(['arecord', '-Dac108', '-f', 'S32_LE', '-r', '16000', '-c', '4', 'hello.wav'],
                           stdout=subprocess.PIPE,
                           universal_newlines=True)
        while GPIO.input(KEY[0]) == 0:
            time.sleep(0.01)
        print("Button " + str(0) + " is released.")
        os.system("killall arecord")
        print ("Wait for arecord to terminate.", end='')
        return_code = None
        while return_code == None:
            print (".", end='')
            time.sleep(0.05)
            return_code = process.poll()
        print("terminated")
        print("=============== Terminated ===================")
        os.system("sox hello.wav mono.wav channels 1 norm -0.1")
        recog = subprocess.Popen(['./recognizer.sh', 'mono.wav'],
                     stdout=subprocess.PIPE,
                     universal_newlines=True)
        print ("Wait for recognizer to terminate.", end='')
        duty_cycle   = 0
        direction_up = True
        maxDutyCycle = 50
        return_code = None
        while return_code == None:
            print (".", end='')
            if direction_up == True:
                if duty_cycle < maxDutyCycle:
                    duty_cycle = duty_cycle + 5
                else:
                    duty_cycle = maxDutyCycle
                    direction_up = False
            else:
                if duty_cycle > 0:
                    duty_cycle = duty_cycle - 5
                else:
                    duty_cycle = 0
                    direction_up = True
            statusLED.ChangeDutyCycle(duty_cycle)
            time.sleep(0.05)
            return_code = recog.poll()
        print("terminated")
        statusLED.ChangeDutyCycle(0)
        brightness = False
        for output in recog.stdout.readlines():
            print(output.strip())
            if brightness == True:
            	result = re.findall(r'_(\d+)_', output)
            	for i in result:
                    print ("Result of brightness = " + i)
                    outLED.ChangeDutyCycle(int(i, base=10))
                    ringValue = int(24 * float(int(i, base=10)) / 100.0)
                    ringWrite([0, ringValue, 0, 0] * PIXELS_N)
            if "_LIGHTON_" in output:
                print ("Recognized light on.")
                outLED.ChangeDutyCycle(100)
                ringWrite([0, 24, 0, 0] * PIXELS_N)
            if "_LIGHTOFF_" in output:
                print ("Recognized light off.")
                outLED.ChangeDutyCycle(0)
                ringWrite([0, 0, 0, 0] * PIXELS_N)
            if "_BRIGHTNESS_" in output:
                print ("Recognized brightness, will check numbers.")
                brightness = True
