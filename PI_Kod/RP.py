import time
import board
import busio
import requests   # Required for WiFi
from adafruit_ads1x15.ads1015 import ADS1015
from adafruit_ads1x15.analog_in import AnalogIn
from adafruit_ads1x15.ads1015 import P0 #Remember, global variable for some godforsaken reason
import numpy as np
from scipy.signal import butter, lfilter
import matplot.pyplot as plt

#Potential WiFi code currently base code
wifi_url = "https://6b5f-2001-6b0-1-1041-e579-c382-aedd-a8df.ngrok-free.app/data"  # <-- URL/IP

def send_bpm_over_wifi(bpm):
	try:
    	response = requests.post(wifi_url, json={
  "bpm": 50,
  "ekg": [7.0, 3.0, -10.0, 20.0, 15.0],
  "emg": [1.0, 20.0, -20.0, 2.0, -10.0]
})
    	print(f"WiFi POST status: {response.status_code}")
	except Exception as e:
    	print("WiFi error:", e)

nyq=50
low=0.002
high=0.6
order=4

b, a=butter(order,[low,high], btype='band')
zi = np.zeros(max(len(a),len(b) -1))

i2c = busio.I2C(board.SCL, board.SDA)  # Use I2C communication

ads = ADS1015(i2c)  # Connect to ADS via I2C
channel0 = AnalogIn(ads,P0)
now = 0
U_THRESHOLD = 0.6 # Must be adjusted based on testing to find the correct peak voltage
L_THRESHOLD = 0.2  # Must be adjusted based on testing to find the correct peak voltage
VL_THRESHOLD=0.9
VU_THRESHOLD=2
last_beat = 0
beats = []  # Array of timestamps for heartbeats
voltage=1.5
last_voltage=0

plt.ion()
fig,ax= plt.subplots()
line, =ax.plot([],[], lw=2)
xdata, ydata= [],[]
ax.set_xlim(0,500)
ax.set_ylim(0,1)

while True:
	last_voltage =voltage
	voltage = channel0.voltage
	y, zi = lfilter(b, a, [voltage], zi=zi)
	y=y[0]
	last = now
	now = time.time()  # Get the current time
    
	xdata.append(len(xdata))
	ydata.append(y)
    
	if len(xdata)>500:
    	xdata=xdata[1:]
    	ydata=ydata[1:]
   	 
	line.set_xdata(xdata)
	line.set_ydata(ydata)
	ax.relim()
	ax.autoscale_view()
	plt.pause(0.001)
    
    
    
	#print(f"Voltage: {channel0.voltage:.3f} V")  # debug (may spam console ? consider removing even during testing)
	#print(f"Heartbeat: {now-last:.3}")
	if voltage-last_voltage > -U_THRESHOLD and voltage-last_voltage < -L_THRESHOLD and VL_THRESHOLD<voltage<VU_THRESHOLD and now - last_beat > 0.4:  # Wait 0.24 seconds between detections
    	print(f"Heartbeat: {now-last_beat:.2f}")  # Debug
    	#print(f"Voltage: {voltage:.3f} V")
    	#print(f"Voltage: {last_voltage:.3f} V")
    	beats.append(now)  # Store the new beat timestamp
    	last_beat = now
   	 
	if len(beats) > 10 :#and now - beats[0] > 10:  # Minimum interval between BPM calculations (10 seconds for now)
    	bpm = (len(beats) - 1) / (beats[-1] - beats[0]) * 60  # (Number of beats between first and last) / (time between them) * 60
    	print(f"BPM: {bpm:.1f}") #Debug
    	beats = beats[-1:]  # Keep only the most recent beat timestamp
    	#send_bpm_over_bluetooth(bpm)  # Send over Bluetooth
    	#send_bpm_over_wifi(bpm)  	# Send over WiFi

	time.sleep(0.01)


Uppdaterad kod 
import time
import board
import busio
import requests   # Required for WiFi
from adafruit_ads1x15.ads1015 import ADS1015
from adafruit_ads1x15.analog_in import AnalogIn
from adafruit_ads1x15.ads1015 import P0 #Remember, global variable for some godforsaken reason
import numpy as np
from scipy.signal import butter, lfilter
import matplotlib.pyplot as plt

#Potential WiFi code currently base code
wifi_url = "https://a302-130-237-96-138.ngrok-free.app/data"  # API endpoint URL/IP

def send_bpm_over_wifi(bpm):
	try:
    	response = requests.post(wifi_url, json={
  "bpm": 50,
  "ekg": [7.0, 3.0, -10.0, 20.0, 15.0],
  "emg": [1.0, 20.0, -20.0, 2.0, -10.0]
})
    	print(f"WiFi POST status: {response.status_code}")
	except Exception as e:
    	print("WiFi error:", e)

nyq=4
low=0.025
high=0.99
order=2

b, a=butter(order,[low, high], btype='band')
zi = np.zeros(max(len(a),len(b)) -1)

i2c = busio.I2C(board.SCL, board.SDA)  # Use I2C communication

ads = ADS1015(i2c)  # Connect to ADS via I2C
channel0 = AnalogIn(ads,P0)
now = 0
U_THRESHOLD = 0.6 # Must be adjusted based on testing to find the correct peak voltage
L_THRESHOLD = 0.2  # Must be adjusted based on testing to find the correct peak voltage
VL_THRESHOLD=0.9
VU_THRESHOLD=2
last_beat = 0
beats = []  # Array of timestamps for heartbeats
voltage=0
last_voltage=0

plt.ion()
fig,ax= plt.subplots()
line, =ax.plot([],[], lw=2)
xdata, ydata= [],[]
ax.set_xlim(0,100)
ax.set_ylim(-1,1)

while True:
	last_voltage =voltage
	voltage = channel0.voltage
	y, zi = lfilter(b, a, [voltage], zi=zi)
	y=y[0]
	last = now
	now = time.time()  # Get the current time
    
	xdata.append(len(xdata))
	ydata.append(y)
    
	if len(xdata)>1000:
    	xdata=xdata[1:]
    	ydata=ydata[1:]
   	 
	line.set_xdata(xdata)
	line.set_ydata(ydata)
	ax.relim()
	ax.autoscale_view()
	plt.pause(0.001)
    
    
    
	print(f"Voltage: {channel0.voltage:.3f} V")  # debug (may spam console ? consider removing even during testing)
	#print(f"Heartbeat: {now-last:.3}")
	if voltage-last_voltage > -U_THRESHOLD and voltage-last_voltage < -L_THRESHOLD and VL_THRESHOLD<voltage<VU_THRESHOLD and now - last_beat > 0.4:  # Wait 0.2 seconds between detections
    	print(f"Heartbeat: {now-last_beat:.2f}")  # Debug
    	#print(f"Voltage: {voltage:.3f} V")
    	#print(f"Voltage: {last_voltage:.3f} V")
    	beats.append(now)  # Store the new beat timestamp
    	last_beat = now
   	 
	if len(beats) > 10 :#and now - beats[0] > 10:  # Minimum interval between BPM calculations (10 seconds for now)
    	bpm = (len(beats) - 1) / (beats[-1] - beats[0]) * 60  # (Number of beats between first and last) / (time between them) * 60
    	print(f"BPM: {bpm:.1f}") #Debug
    	beats = beats[-1:]  # Keep only the most recent beat timestamp
    	#send_bpm_over_bluetooth(bpm)  # Send over Bluetooth
    	send_bpm_over_wifi(bpm)  	# Send over WiFi

	time.sleep(0.01)

Uppdaterad kod 05-02

import time
import board
import busio
import requests   # Required for WiFi
from adafruit_ads1x15.ads1015 import ADS1015
from adafruit_ads1x15.analog_in import AnalogIn
from adafruit_ads1x15.ads1015 import P0 #Remember, global variable for some godforsaken reason
import numpy as np
from scipy.signal import butter, lfilter
import matplotlib.pyplot as plt

#Potential WiFi code currently base code
wifi_url = "https://91ce-130-229-141-175.ngrok-free.app/data"  # <-- URL/IP

def send_bpm_over_wifi(bpm):
    try:
        response = requests.post(wifi_url, json={
  "bpm": 50,
  "ekg": [7.0, 3.0, -10.0, 20.0, 15.0],
  "emg": [1.0, 20.0, -20.0, 2.0, -10.0]
})
        print(f"WiFi POST status: {response.status_code}")
    except Exception as e:
        print("WiFi error:", e)

nyq=20
low=0.005
high=0.2
order=4

b, a=butter(order,[low, high], btype='band')
zi = np.zeros(max(len(a),len(b)) -1)

i2c = busio.I2C(board.SCL, board.SDA)  # Use I2C communication

ads = ADS1015(i2c)  # Connect to ADS via I2C
channel0 = AnalogIn(ads,P0) 
now = 0
U_THRESHOLD = 0.6 # Must be adjusted based on testing to find the correct peak voltage
L_THRESHOLD = 0.2  # Must be adjusted based on testing to find the correct peak voltage
VL_THRESHOLD=0.9
VU_THRESHOLD=2
last_beat = 0
beats = []  # Array of timestamps for heartbeats
voltage=0
last_voltage=0
y_last=0

while True:
    last_voltage =voltage
    voltage = channel0.voltage

    y, zi = lfilter(b, a, [voltage], zi=zi)
    y=y[0]
    last = now
    now = time.time()  # Get the current time
    
    
    
    
    
    print(f"Voltage: {channel0.voltage:.3f} V")  # debug (may spam console ? consider removing even during testing)
    print(f"Time between samples: {now-last:.3}")
    print(f"Voltage:{y:.3f} V")
    """
    
    if voltage-last_voltage > -U_THRESHOLD and voltage-last_voltage < -L_THRESHOLD and VL_THRESHOLD<voltage<VU_THRESHOLD and now - last_beat > 0.4:  # Wait 0.2 seconds between detections
        print(f"Heartbeat: {now-last_beat:.2f}")  # Debug
        #print(f"Voltage: {voltage:.3f} V")
        #print(f"Voltage: {last_voltage:.3f} V")
        beats.append(now)  # Store the new beat timestamp
        last_beat = now
"""
    if y-y_last>U_THRESHOLD and y-y_last < L_THRESHOLD and now - last_beat > 0.2:  # Wait 0.2 seconds between detections
        print(f"Heartbeat: {now-last_beat:.2f}")  # Debug
        #print(f"Voltage: {voltage:.3f} V")
        #print(f"Voltage: {last_voltage:.3f} V")
        beats.append(now)  # Store the new beat timestamp
        last_beat = now
        

    if len(beats) > 10 :#and now - beats[0] > 10:  # Minimum interval between BPM calculations (10 seconds for now)
        bpm = (len(beats) - 1) / (beats[-1] - beats[0]) * 60  # (Number of beats between first and last) / (time between them) * 60
        print(f"BPM: {bpm:.1f}") #Debug
        beats = beats[-1:]  # Keep only the most recent beat timestamp
        send_bpm_over_bluetooth(bpm)  # Send over Bluetooth
        send_bpm_over_wifi(bpm)      # Send over WiFi
    y_last= y
    time.sleep(0.01)

