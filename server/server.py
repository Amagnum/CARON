import urllib.request
from flask import Flask, request, jsonify
import os
import cv2
import numpy as np
from tqdm import tqdm
from preprocessing import parse_annotation
from utils import draw_boxes
from frontend import YOLO

app = Flask(__name__)

os.environ["CUDA_DEVICE_ORDER"]="PCI_BUS_ID"
os.environ["CUDA_VISIBLE_DEVICES"]="0"

weights_path = "trained_wts.h5"
image_path   = "1.jpg"

yolo = YOLO(backend             = "Full Yolo",
            input_size          = 416, 
            labels              = ["Potholes"], 
            max_box_per_image   = 15,
            anchors             = [0.57273, 0.677385, 1.87446, 2.06253, 3.33843, 5.47434, 7.88282, 3.52778, 9.77052, 9.16828]
        )
yolo.load_weights(weights_path)

@app.route('/', methods=['GET', 'POST'])
def predict():
    import keras.backend.tensorflow_backend as tb
    tb._SYMBOLIC_SCOPE.value = True

    url = request.form.get('url')
    urllib.request.urlretrieve(url, '1.jpg')
    image = cv2.imread("1.jpg")
    boxes = yolo.predict(image)
    image = draw_boxes(image, boxes, "Pothole")

    # print(len(boxes), 'boxes are found')

    cv2.imwrite("detected.jpg", image)
    return jsonify(
        NUM_POTHOLES=len(boxes),
        coordinates=boxes
    )

if __name__ == '__main__':
    app.run(host="0.0.0.0",port=5000,threaded=False)