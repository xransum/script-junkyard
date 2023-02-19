import cv2
import tkinter as tk
import numpy as np
from tkinter import filedialog


def fileselector(file_types):
    root = tk.Tk()
    root.withdraw() # hide the root window
    filepath = filedialog.askopenfilename(filetypes=ftypes)
    return filepath

# default values
lower_hsv = np.array([0, 0, 0])
upper_hsv = np.array([179, 255, 255])


# Get the current positions of all trackbars and update
# the global HSV values
def update_hsvs():
    global lower_hsv, upper_hsv

    # Update the global HSV values with the trackbar values
    lower_hsv = np.array([
        cv2.getTrackbarPos('Low H', 'Controls'),
        cv2.getTrackbarPos('Low S', 'Controls'),
        cv2.getTrackbarPos('Low V', 'Controls')
    ], np.uint8)

    upper_hsv = np.array([
        cv2.getTrackbarPos('High H', 'Controls'),
        cv2.getTrackbarPos('High S', 'Controls'),
        cv2.getTrackbarPos('High V', 'Controls')
    ], np.uint8)

    print(lower_hsv, upper_hsv)

def run(image):
    # Create a window named 'Controls' for trackbar
    cv2.namedWindow('Controls', 2)

    #cv2.resizeWindow('Controls', 550, 10)
    cv2.resizeWindow('Controls', 500, 300)

    # Create trackbars for lower HSV values
    cv2.createTrackbar('Low H', 'Controls', lower_hsv[0], 179, update_hsvs)
    cv2.createTrackbar('Low S', 'Controls', lower_hsv[1], 255, update_hsvs)
    cv2.createTrackbar('Low V', 'Controls', lower_hsv[2], 255, update_hsvs)

    # Create trackbars for upper HSV values
    cv2.createTrackbar('High H', 'Controls', upper_hsv[0], 179, update_hsvs)
    cv2.createTrackbar('High S', 'Controls', upper_hsv[1], 255, update_hsvs)
    cv2.createTrackbar('High V', 'Controls', upper_hsv[2], 255, update_hsvs)

    while True:
        # Create the hsv from the bgr image
        image_hsv = cv2.cvtColor(image, cv2.COLOR_BGR2HSV)
        image_mask = cv2.inRange(image_hsv, lower_hsv, upper_hsv)
        image_res = cv2.bitwise_and(image, image, mask=image_mask)

        # Show all the windows
        # cv2.imshow("BGR", image)
        # cv2.imshow("HSV", image_hsv)
        # cv2.imshow("Mask", image_mask)
        # add text to image

        # stack the mask, orginal frame and the filtered result
        stacked = np.hstack((
            image,
            cv2.cvtColor(image_mask, cv2.COLOR_GRAY2BGR),
            image_res
        ))

        # Show this stacked frame at 40% of the size.
        # Uncomment below to resize the stacked images to 50% of the original size
        # cv2.imshow('Trackbars', cv2.resize(stacked, None, fx=0.5, fy=0.5))
        cv2.imshow('Trackbars', stacked)

        # If the user presses ESC then exit the program
        if cv2.waitKey(25) & 0xFF == ord('q'):
            cv2.destroyAllWindows()
            break

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