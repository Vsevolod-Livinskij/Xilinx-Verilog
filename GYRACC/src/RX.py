import time
import serial

def bin(s):
	return str(s) if s<=1 else bin(s>>1) + str(s&1)

def twos_comp(val, bits):
    """compute the 2's compliment of int value val"""
    if (val & (1 << (bits - 1))) != 0: # if sign bit is set e.g., 8bit: 128-255
        val = val - (1 << bits)        # compute negative value
    return val                         # return positive value as is

def pad_zero (val):
	while (len(val) < 8):
		val = "0" + val
	return val

# configure the serial connections (the parameters differs on the device you are connecting to)
ser = serial.Serial(
	port='/dev/serial/by-id/usb-Prolific_Technology_Inc._USB-Serial_Controller-if00-port0',
	baudrate=9600,
	parity=serial.PARITY_NONE,
	stopbits=serial.STOPBITS_ONE,
	bytesize=serial.EIGHTBITS
)
ser.isOpen()

del_num = 0
prev_del = False

data_num = 0
out_low = ''
out_high = ''

init_sample_count = 0
sample_num = 100
alpha = 0.3
x_offset = 0.0
y_offset = 0.0
z_offset = 0.0

xp = 0.0
yp = 0.0
zp = 0.0

x_deg = 0.0
y_deg = 0.0
z_deg = 0.0

data = 0.0

while 1 :
	out = ''
#	while ser.inWaiting() > 0:
	out = ser.read(1)
#        print("out " + str(ord(out)) + " | " + bin(ord(out)))
	if out != '':
                if (del_num == 5):
                        data_num += 1
                        if (data_num % 2 == 1):
                                out_low = pad_zero(bin(ord(out)))
                        else:
                                out_high = pad_zero(bin(ord(out)))
#				print(out_high + out_low)
#				print (twos_comp(int(out_high + out_low, 2), 16))

				data = twos_comp(int(out_high + out_low, 2), 16) *  0.00875
#				print(data)

			if (init_sample_count < sample_num * 3 and data_num % 2 == 0):
				init_sample_count += 1
				if (data_num == 2):
					x_offset += data
				if (data_num == 4):
                                        y_offset += data
				if (data_num == 6):
                                        z_offset += data
			elif (data_num % 2 == 0):
				prev_val = 0.0
				offset = 0.0
				form_str = ""
				if (data_num == 2):
					form_str = "x"
					prev_val = xp
					offset = x_offset
                                if (data_num == 4):
                                        form_str = "y"
                                        prev_val = yp
                                        offset = y_offset
                                if (data_num == 6):
                                        form_str = "z"
                                        prev_val = zp
                                        offset = z_offset
				out_data = (data - offset / sample_num) * alpha + (prev_val * (1.0 - alpha))
				print(form_str + " : " + str(out_data))

				axis_deg = 0.0
				if (data_num == 2):
					x_deg += out_data * 0.01
					axis_deg = x_deg
					xp = out_data
                                if (data_num == 4):
					y_deg += out_data * 0.01
					axis_deg = y_deg
					yp = out_data
                                if (data_num == 6):
					z_deg += out_data * 0.01
					axis_deg = z_deg
					zp = out_data
				print(form_str + "_deg: " + str(axis_deg))

                        if (data_num == 6):
                                del_num = 0
				prev_del = False
                                data_num = 0
			continue

		if (ord(out) == 85):
			if (prev_del):
				del_num += 1
			prev_del = True
		else:
			del_num = 0
			prev_del = False
 #       print("del_num " + str(del_num))
#        print("prev_del " + str(prev_del))
#        print("data_num " + str(data_num))
