//
//  SelfieViewController.swift
//  MyMaps
//
//  Created by Karahanyan Levon on 24.11.2021.
//

import UIKit
import AVFoundation

class PhotoViewController: UIViewController {
    
    // Замыкание, которое будет вызвано, когда мы получим изображение
    var onTakePicture: ((UIImage) -> Void)?
    
    // Сессия видеозахвата
    var captureSession: AVCaptureSession?
    // Объект, отвечающий за получение фотоданных
    var cameraOutput: AVCapturePhotoOutput?
    // Слой, который отображает данные с камеры в реальном времени
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    // Переменная, которая запомнит, в какой ориентации был телефон
    // во время снимка
    var deviceOrientationOnCapture: UIDeviceOrientation?
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // При изменении вьюшек меняем размер слоя, иначе он будет некрасиво
        // смотреться при повороте
        previewLayer?.frame = view.layer.bounds
    }
    
    // Отслеживаем повороты устройства
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        
        // Поддерживает ли наш слой изменение ориентации
        if previewLayer?.connection?.isVideoOrientationSupported == true {
            // Устанавливаем текущую ориентацию, иначе изображение будет перевёрнутым
            previewLayer?.connection?.videoOrientation = UIDevice.current.orientation.getAVCaptureVideoOrientationFromDevice()
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Создаём объект, отвечающий за получение фотоданных
        let cameraOutput = makeCameraOutput()
        self.cameraOutput = cameraOutput
        // Создаём сессию видеозахвата
        guard let captureSession = makeCameraSession(cameraOutput: cameraOutput) else { return }
        self.captureSession = captureSession
        // Настраиваем слой, который отображает данные с камеры в реальном времени
        configurePreviewLayer(captureSession, cameraOutput)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Как только экран становится виден, запускаем сессию видеозахвата
        // В этот момент мы подключаемся к камере и считываем с неё изображение
        // в реальном времени
        captureSession?.startRunning()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Как только экран закрывается, останавливаем сессию видеозахвата
        captureSession?.stopRunning()
    }
    
    @IBAction func takePicture(_ sender: Any) {
        // Создаём настройки получения снимка
        // Снимок будет получен в формате jpeg
        let settings = AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg])
        // Делаем снимок (получаем текущую картинку в формате, заданном выше)
        cameraOutput?.capturePhoto(with: settings, delegate: self)
    }
    
    // Ищем среди датчиков устройства обычную переднюю камеру
    func cameraDeviceFind() -> AVCaptureDevice? {
        // Настройки поиска
        let discoverySession = AVCaptureDevice.DiscoverySession(
            deviceTypes: [.builtInWideAngleCamera], // Обычная передняя камера
            mediaType: .video,                      // Тип устройства – камера
            position: .front                        // Передняя камера
        )
        let devices = discoverySession.devices      // Все найденные устройства
        // Первое найденное устройство типа «передняя камера»
        let device = devices
            .first(where: { $0.hasMediaType(AVMediaType.video) && $0.position == .front })
        return device
    }
    
    func makeCameraOutput() -> AVCapturePhotoOutput {
        // Создаём объект, который будет получать данные из сессии видеозахвата
        // в момент получения снимка
        let cameraOutput = AVCapturePhotoOutput()
        // Здесь мы можем указать различные настройки,
        // в документации их описано намного больше
        // Высокое разрешение
        cameraOutput.isHighResolutionCaptureEnabled = true
        // Живые фото отключены
        cameraOutput.isLivePhotoCaptureEnabled = false
        return cameraOutput
    }
    
    func makeCameraSession(cameraOutput: AVCapturePhotoOutput) -> AVCaptureSession? {
        // Создаём сессию видеозахвата
        let captureSession = AVCaptureSession()
        
        guard
            // Если мы нашли переднюю камеру
            let device = cameraDeviceFind(),
            // Если смогли создать из неё устройство получения данных
            let input = try? AVCaptureDeviceInput(device: device),
            // Если можем добавить в сессию в качестве источника данных
            captureSession.canAddInput(input) else {
                return nil
            }
        // то добавляем в сессию в качестве источника данных
        captureSession.addInput(input)
        // Устанавливаем предустановленный режим съёмки фото
        captureSession.sessionPreset = AVCaptureSession.Preset.photo
        // Добавляем объект, отвечающий за получение фотоданных
        // в качестве приёмника данных
        captureSession.addOutput(cameraOutput)
        
        return captureSession
    }
    
    func configurePreviewLayer(_ captureSession: AVCaptureSession, _ cameraOutput: AVCapturePhotoOutput) {
        // Создаём слой, который отображает данные с камеры в реальном времени
        let previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        // Добавляем его на корневую вьюшку экрана
        view.layer.insertSublayer(previewLayer, at: 0)
        // Устанавливаем размеры слоя равными размерам текущей вьюшки
        previewLayer.frame = view.layer.bounds
        
        self.previewLayer = previewLayer
    }
    
}

extension PhotoViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        // Преобразуем фотоданные снимка в изображение
        guard
            // Если мы получили фотоданные
            let imageData = photo.fileDataRepresentation(),
            // Если смогли сделать из них изображение
            let uiImage = UIImage(data: imageData),
            // Если извлекли кор изображения
            let cgImage = uiImage.cgImage,
            // Если есть запомненная ориентация
            let deviceOrientationOnCapture = self.deviceOrientationOnCapture else {
                return
                
            }
        // то создаём изображение из кор изображения, при этом разворачиваем его,
        // чтобы оно не оказалось перевёрнутым
        let image = UIImage(
            cgImage: cgImage,
            scale: 1.0,
            orientation: deviceOrientationOnCapture.getUIImageOrientationFromDevice()
        )
        
        // Вызываем замыкание, передав в него изображение
        onTakePicture?(image)
        
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput, willBeginCaptureFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
        // Перед началом извлечения фотоданных запоминаем текущую ориентацию устройства
        deviceOrientationOnCapture = UIDevice.current.orientation
    }
}

fileprivate extension UIDeviceOrientation {
    // Преобразование текущей ориентации экрана в ориентацию изображения
    func getUIImageOrientationFromDevice() -> UIImage.Orientation {
        let orientation: UIImage.Orientation
        switch self {
        case .portrait, .faceUp:
            orientation = .right
        case .portraitUpsideDown, .faceDown:
            orientation = .left
        case .landscapeLeft:
            orientation = .down
        case .landscapeRight:
            orientation = .up
        case .unknown:
            orientation = .down
        default:
            orientation = .right
        }
        return orientation
    }
    
    // Преобразование текущей ориентации экрана в ориентацию видеозахвата
    func getAVCaptureVideoOrientationFromDevice() -> AVCaptureVideoOrientation {
        let orientation: AVCaptureVideoOrientation
        switch self {
        case .portrait, .faceUp:
            orientation = .portrait
        case .portraitUpsideDown, .faceDown:
            orientation = .portraitUpsideDown
        case .landscapeLeft:
            orientation = .landscapeRight
        case .landscapeRight:
            orientation = .landscapeLeft
        case .unknown:
            orientation = .landscapeLeft
        default:
            orientation = .portrait
        }
        return orientation
    }
}
