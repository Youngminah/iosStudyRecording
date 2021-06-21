//
//  QRScannerViewController.swift
//  QRCodeApp
//
//  Created by Farukh IQBAL on 21/12/2020.
//

import UIKit
import AVFoundation

class QRScannerController: UIViewController {
    
    var captureSession = AVCaptureSession() //비디오에서 들어온 데이터 인풋을 아웃풋으로 조정하는데 쓰이는 객체
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var qrCodeFrameView: UIView?
    
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var topBar: UIView!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Get the back-facing camera for capturing videos
        guard let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) else {
            print("후반 카메라를 가져오는 것에 실패함.")
            return
        }
        
        do {
            //Get an instance of the AVCaptureDeviceInput class using the previous device object
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            //Set the input device on the capture session
            captureSession.addInput(input) //메타데이터 아웃풋을 내놓는다. 큐알 코드 읽기의 핵심!!
            
            //AVCaptureMetadataOutput 객체 초기화 & 캡쳐 세션에 설정.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to excute the call back
            // 새로운 메타 데이터가 캡쳐되면 처리를 위해 델리게이트 객체에 전달된다.
            // 델리게이트 메서드를 실행할 디스패치 큐를 설정하는 것. (애플문서에 따르면 디스패치큐는 직렬이여야한다.)
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr] // 타입도 중요함. qr을 원하는 것을 명시한다.
            
            //비디오 미리보기 레이어를 설정해주고 서브레이어를 추가한다.
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            view.layer.addSublayer(videoPreviewLayer!)
            
            captureSession.startRunning()
            
            //Move the message label and top bar to the front
            view.bringSubviewToFront(messageLabel)
            view.bringSubviewToFront(topBar)
            
            //큐알코드가 인식되었을 때에 프레임 틀에 하이라이트 주기 , 이걸 설정하기 전에는 자동으로 0이 들어가있어서 눈에 안보였었음.
            if let qrCodeFrameView = qrCodeFrameView {
                qrCodeFrameView.layer.borderColor = UIColor.yellow.cgColor
                qrCodeFrameView.layer.borderWidth = 2
                view.addSubview(qrCodeFrameView)
                view.bringSubviewToFront(qrCodeFrameView)
            }
            
        } catch {
            print(error)
            return
        }
    }
}

//이 프로토콜은 모든 메타데이터가 감지되면 가로채는 데 사용됨. 사람이 읽을 수 있는 형식으로 변환.
extension QRScannerController: AVCaptureMetadataOutputObjectsDelegate {
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // 메타데이터오브젝트 배열에 뭐가 있는지 확인
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        //메타데이터 얻기
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if metadataObj.type == AVMetadataObject.ObjectType.qr {
            //메타데이터가 큐알이라면 현재 상태 레이블에 표시해주기
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
                messageLabel.text = metadataObj.stringValue
            }
        }
    }
}
