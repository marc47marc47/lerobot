#!/usr/bin/env python3
import cv2

def capture_frame(device="/dev/video0", outfile="frame.jpg"):
    # 開啟相機
    cap = cv2.VideoCapture(device, cv2.CAP_V4L2)
    if not cap.isOpened():
        raise IOError(f"Cannot open device {device}")

    # 設定解析度 (與 C 範例一致 640x480)
    cap.set(cv2.CAP_PROP_FRAME_WIDTH, 720)
    cap.set(cv2.CAP_PROP_FRAME_HEIGHT, 640)

    # 擷取一張 frame
    ret, frame = cap.read()
    if not ret:
        raise RuntimeError("Failed to capture frame")

    # 儲存 JPEG
    cv2.imwrite(outfile, frame)
    print(f"Saved {outfile}")

    # 釋放裝置
    cap.release()

if __name__ == "__main__":
    capture_frame()

