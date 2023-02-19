import win32gui
import win32ui
import win32con
import win32api
import cv2
import numpy as np
from ctypes import windll
from PIL import Image, ImageGrab
from difflib import get_close_matches
from time import time
from . import maths


# Get the region of a running window id
def get_window_region(hwnd):
    rect = win32gui.GetWindowRect(hwnd)
    return rect

# Take window region and determine size from it
def get_window_size(rect):
    x1, y1, x2, y2 = rect[:4]
    w = x2-x1
    h = y2-y1
    return h, w

# List of all running windows by (hwnd, name)
def get_app_windows():
    app_wins = []
    def callback(hwnd, extra):
        name = win32gui.GetWindowText(hwnd)
        app_wins.append((hwnd, name))

    win32gui.EnumWindows(callback, None)
    return app_wins

# Find a window that has the closest match to a 
# given name
def find_window_by_name(name):
    app_wins = get_app_windows()
    names = [n for h, n in app_wins if n]
    close_matches = get_close_matches(name, names, n=1, cutoff=0.3)

    for match in close_matches:
        for hwnd, name in app_wins:
            if match == name:
                return hwnd, name

    return None, None

# Take a screenshot of a window even if the window has 
# been minimized
def window_capture(hwnd):
    start_time = time()
    rect = get_window_region(hwnd) # position in space
    w, h = get_window_size(rect) # width, height

    hwindc = win32gui.GetWindowDC(hwnd)
    mfcdc  = win32ui.CreateDCFromHandle(hwindc)
    memdc = mfcdc.CreateCompatibleDC()

    bmp = win32ui.CreateBitmap()
    # bmp.CreateCompatibleBitmap(mfcdc, w, h) # 
    bmp.CreateCompatibleBitmap(mfcdc, h, w)

    memdc.SelectObject(bmp)
    result = windll.user32.PrintWindow(hwnd, memdc.GetSafeHdc(), 0)

    bmpinfo = bmp.GetInfo()
    bmpstr = bmp.GetBitmapBits(True)

    im = Image.frombuffer('RGB', (bmpinfo['bmWidth'], bmpinfo['bmHeight']), 
        bmpstr, 'raw', 'BGRX', 0, 1)

    win32gui.DeleteObject(bmp.GetHandle())
    memdc.DeleteDC()
    mfcdc.DeleteDC()
    win32gui.ReleaseDC(hwnd, hwindc)

    image = np.asarray(im)
    return image

# Take a screenshot of a region
def screen_capture(region=None):
    if region is None:
        # below returns the 'root' HWND of desktop calling thread is associated with
        hwin = win32gui.GetDesktopWindow()
        # below returns the HDESK of whichever desktop currently is active and receiving user input
        # hwin = win32gui.OpenInputDesktop()
        region = win32gui.GetWindowRect(hwin)

    x1, y1, x2, y2 = region
    w = x2-x1
    h = y2-y1

    hwindc = win32gui.GetWindowDC(hwin)
    mfcdc = win32ui.CreateDCFromHandle(hwindc)
    memdc = mfcdc.CreateCompatibleDC()

    bmp = win32ui.CreateBitmap()
    bmp.CreateCompatibleBitmap(mfcdc, w, h)

    memdc.SelectObject(bmp)
    memdc.BitBlt((0, 0), (w, h), mfcdc, (left, top), win32con.SRCCOPY)

    signedIntsArray = bmp.GetBitmapBits(True)
    image = np.frombuffer(signedIntsArray, dtype="uint8")
    image.shape = (h, w, 4)

    mfcdc.DeleteDC()
    memdc.DeleteDC()

    win32gui.ReleaseDC(hwin, hwindc)
    win32gui.DeleteObject(bmp.GetHandle())

    return image

# Alternative to screen_capture
def region_capture(region):
    image = np.array(ImageGrab.grab(bbox=region))
    image = cv2.cvtColor(img, cv2.COLOR_RGB2BGR)
    return image

