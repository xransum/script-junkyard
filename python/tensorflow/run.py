import sys
import os
import cv2
import numpy as np
import six.moves.urllib as urllib
import tarfile
import tensorflow as tf
from glob import glob
from PIL import Image
from matplotlib import pyplot as plt


root_self = os.path.abspath(os.path.dirname(__file__))
sys.path.append(os.path.join(root_self, 'models'))

from object_detection.utils import label_map_util
from object_detection.utils import visualization_utils as vis_utils

tmp_dir = os.path.join(root_self, 'tmp')
if not os.path.exists(tmp_dir):
    os.makedirs(tmp_dir)

# -- Model Preparation --
# What model to download.
MODEL_NAME = 'ssd_mobilenet_v1_coco_11_06_2017'
MODEL_FILE = MODEL_NAME + '.tar.gz'
MODEL_CACHE_PATH = os.path.join(tmp_dir, MODEL_NAME)
MODEL_CACHE_FILE = os.path.join(tmp_dir, MODEL_FILE)
# Path to frozen detection graph. 
# This is the actual model that is used for the object detection.
PATH_TO_CKPT = os.path.join(MODEL_CACHE_PATH, 'frozen_inference_graph.pb')
# List of the strings that is used to add correct label for each box.
PATH_TO_LABELS = os.path.join('models/object_detection/data', 'mscoco_label_map.pbtxt')
NUM_CLASSES = 90

# --- Download Model ---
DOWNLOAD_BASE = 'http://download.tensorflow.org/models/object_detection/'
opener = urllib.request.URLopener()
opener.retrieve(DOWNLOAD_BASE + MODEL_FILE, MODEL_CACHE_FILE)

tar_file = tarfile.open(MODEL_CACHE_FILE)
tar_file.extractall(path=tmp_dir)
tar_file.close()
if os.path.exists(MODEL_CACHE_FILE):
    os.remove(MODEL_CACHE_FILE)

# --- Load a (frozen) Tensorflow model into memory. ---
detection_graph = tf.Graph()
with detection_graph.as_default():
    od_graph_def = tf.compat.v1.GraphDef()
    
    with tf.io.gfile.GFile(PATH_TO_CKPT, 'rb') as fid:
        serialized_graph = fid.read()
        od_graph_def.ParseFromString(serialized_graph)
        tf.import_graph_def(od_graph_def, name='')

# ## Loading label map
# Label maps map indices to category names, so that when our convolution network predicts `5`, we know that this corresponds to `airplane`.  Here we use internal utility functions, but anything that returns a dictionary mapping integers to appropriate string labels would be fine
label_map = label_map_util.load_labelmap(PATH_TO_LABELS)
categories = label_map_util.convert_label_map_to_categories(label_map, max_num_classes=NUM_CLASSES, use_display_name=True)
category_index = label_map_util.create_category_index(categories)

# -- Detection --
# For the sake of simplicity we will use only 2 images:
# image1.jpg, image2.jpg
# If you want to test the code with your images, just add path to the images to the TEST_IMAGE_PATHS.
PATH_TO_TEST_IMAGES_DIR = os.path.abspath(os.path.join(root_self, 'models/object_detection/test_images'))
TEST_IMAGE_PATHS = [i for i in glob(os.path.join(PATH_TO_TEST_IMAGES_DIR, "image*.jpg"))]


# Size, in inches, of the output images.
IMAGE_SIZE = (12, 8)

# ## Helper code
def load_image_into_numpy_array(image):
    im_width, im_height = image.size
    return np.array(image.getdata()).reshape( (im_height, im_width, 3) ).astype(np.uint8)

# -- Running --
with detection_graph.as_default():
    with tf.compat.v1.Session(graph=detection_graph) as sess:
        for image_path in TEST_IMAGE_PATHS:
            image = Image.open(image_path)

            # the array based representation of the image will be used later in order to prepare the
            # result image with boxes and labels on it.
            image_np = load_image_into_numpy_array(image)

            # Expand dimensions since the model expects images to have shape: [1, None, None, 3]
            image_np_expanded = np.expand_dims(image_np, axis=0)
            image_tensor = detection_graph.get_tensor_by_name('image_tensor:0')

            # Each box represents a part of the image where a particular object was detected.
            boxes = detection_graph.get_tensor_by_name('detection_boxes:0')

            # Each score represent how level of confidence for each of the objects.
            # Score is shown on the result image, together with the class label.
            scores = detection_graph.get_tensor_by_name('detection_scores:0')
            classes = detection_graph.get_tensor_by_name('detection_classes:0')
            num_detections = detection_graph.get_tensor_by_name('num_detections:0')

            # Actual detection.
            boxes, scores, classes, num_detections = sess.run([boxes, scores, classes, num_detections],
                feed_dict={image_tensor: image_np_expanded})

            # Visualization of the results of a detection.
            vis_utils.visualize_boxes_and_labels_on_image_array(
                image_np,
                np.squeeze(boxes),
                np.squeeze(classes).astype(np.int32),
                np.squeeze(scores),
                category_index,
                use_normalized_coordinates=True,
                line_thickness=8)

            cv2.imshow('window', image_np)
            if cv2.waitKey(25) & 0xFF == ord('q'):
                cv2.destroyAllWindows()
                break
