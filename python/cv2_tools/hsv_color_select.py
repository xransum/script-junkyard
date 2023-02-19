import cv2
import tkinter as tk
import numpy as np
from tkinter import filedialog

image_hsv = None
# default values
pixel = (0, 0, 0)

def fileselector(file_types):
    root = tk.Tk()
    root.withdraw() # hide the root window
    filepath = filedialog.askopenfilename(filetypes=ftypes)
    return filepath

def check_boundaries(value, tolerance:int, sat_and_brightness=False, upper=False) -> int:
	boundary = 0
	if sat_and_brightness:
		# set the boundary for saturation and value
		boundary = 255
	else:
		# set the boundary for hue
		boundary = 179

	if (value + tolerance) > boundary:
		value = boundary
	elif (value - tolerance) < 0:
		value = 0
	else:
		if upper == True:
			value = value + tolerance
		else:
			value = value - tolerance

	return value

def pick_color(event, x, y, flags, param) -> None:
    global pixel
    
	if event == cv2.EVENT_LBUTTONDOWN:
		pixel = image_hsv[y, x]

		# Hue, saturation, and value (brightness) ranges; tolerance could be adjusted.
		# Set range = 0 for hue and range = 1 for saturation and brightness
		# set upper_or_lower = 1 for upper and upper_or_lower = 0 for lower
		hue_upper = check_boundaries(pixel[0], tolerance=10, sat_and_brightness=False, upper=True)
		hue_lower = check_boundaries(pixel[0], tolerance=10, sat_and_brightness=False, upper=False)
		saturation_upper = check_boundaries(pixel[1], tolerance=10, sat_and_brightness=True, upper=True)
		saturation_lower = check_boundaries(pixel[1], tolerance=10, sat_and_brightness=True, upper=False)
		value_upper = check_boundaries(pixel[2], tolerance=40, sat_and_brightness=True, upper=True)
		value_lower = check_boundaries(pixel[2], tolerance=40, sat_and_brightness=True, upper=False)

		upper =  np.array([hue_upper, saturation_upper, value_upper])
		lower =  np.array([hue_lower, saturation_lower, value_lower])

		print(f'{pixel} - {upper}, {lower}')

		# A monochrome mask for getting a better vision over the colors 
		image_mask = cv2.inRange(image_hsv, lower, upper)
		cv2.imshow("Mask", image_mask)


def run(image=None):
    global image_hsv

    # Mouse events
    cv2.setMouseCallback("Color Selector - HSV", pick_color)
    #cv2.setMouseCallback("Color Selector - BGR", pick_color)
    
    # Create the hsv from the bgr image
    image_hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
    
    # Display images
    cv2.imshow("Color Selector - BGR", image)
    cv2.imshow("Color Selector - HSV", image_hsv)

    cv2.waitKey(0)
    cv2.destroyAllWindows()
    return

if __name__== '__main__':
    filepath = fileselector(file_types=[("JPG", "*.jpg;*.JPG;*.JPEG"),
                                            ("PNG", "*.png;*.PNG"),
                                            ("GIF", "*.gif;*.GIF"),
                                            ("All files", "*.*")])
    if not filepath:
        print('Image or filepath is required.')
        return

    image = cv2.imread(filepath)
    main(image)
