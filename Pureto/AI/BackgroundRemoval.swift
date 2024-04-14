//
//  SwiftUIView.swift
//  Pureto
//
//  Created by Pureto on 24/9/23.
//

import SwiftUI
import Vision
import CoreML
import CoreMedia
import Foundation
import UIKit


class BackgroundRemoval: ObservableObject{
    
    func segmentImage(inputImage: UIImage, completion:@escaping (UIImage?) -> Void) async {
        guard let model = try? VNCoreMLModel(for: DeepLabV3(configuration: .init()).model)
        else { return }
       
        let request = VNCoreMLRequest(model: model, completionHandler: { [self]
            (subRequest: VNRequest, error: Error?) in
//            VNRecognizedTextObservation
            if let observations = subRequest.results as? [VNCoreMLFeatureValueObservation],
               let segmentationmap = observations.first?.featureValue.multiArrayValue {
                let segmentationMask = segmentationmap.image(min: 0, max: 1)
                var outputImage: UIImage? = nil
                outputImage = segmentationMask!.resized(to: inputImage.size, scale: inputImage.scale)
                outputImage = maskInputImage(inputImage: inputImage, outputImage: outputImage ?? UIImage())
                completion(outputImage)
            }
        })
        request.imageCropAndScaleOption = .scaleFill
        DispatchQueue.global().async {

            let handler = VNImageRequestHandler(cgImage: inputImage.cgImage!, options: [:])
            
            do {
                try handler.perform([request])
            }catch {
                print(error)
            }
        }
    }

    func maskInputImage(inputImage: UIImage, outputImage: UIImage) -> UIImage?{
//        let bgImage = UIImage.imageFromColor(color: .orange, size: inputImage.size, scale: inputImage.scale)!
        let bgImage = blurImage(image: inputImage, blur: 15)
        let beginImage = CIImage(cgImage: inputImage.cgImage!)
        let background = CIImage(cgImage: bgImage!.cgImage!)
        let mask = CIImage(cgImage: outputImage.cgImage!)
        
        if let compositeImage = CIFilter(name: "CIBlendWithMask", parameters: [
                                        kCIInputImageKey: beginImage,
                                        kCIInputBackgroundImageKey:background,
                                        kCIInputMaskImageKey:mask])?.outputImage
        {
            let ciContext = CIContext(options: nil)

            let filteredImageRef = ciContext.createCGImage(compositeImage, from: compositeImage.extent)
            
            return UIImage(cgImage: filteredImageRef!)
            
        }
        return nil
    }
    
    func blurImage(image: UIImage, blur:CGFloat) -> UIImage?{
        let context = CIContext(options: nil)
        guard let inputImage = CIImage(image: image) else{return nil}
        let filter = CIFilter(name: "CIGaussianBlur")
        filter?.setValue(inputImage, forKey: kCIInputImageKey)
        filter?.setValue(blur, forKey: kCIInputRadiusKey)
        guard let outputImage = filter?.outputImage,
              let cgImage = context.createCGImage(outputImage, from: inputImage.extent) else{return nil}
        return UIImage(cgImage: cgImage, scale: image.scale, orientation: image.imageOrientation)
    }
}

extension UIImage {
    class func imageFromColor(color: UIColor, size: CGSize=CGSize(width: 1, height: 1), scale: CGFloat) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        color.setFill()
        UIRectFill(CGRect(origin: CGPoint.zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    func resizedImage(for size: CGSize) -> UIImage? {
            let image = self.cgImage
            print(size)
            let context = CGContext(data: nil,
                                    width: Int(size.width),
                                    height: Int(size.height),
                                    bitsPerComponent: image!.bitsPerComponent,
                                    bytesPerRow: Int(size.width),
                                    space: image?.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                    bitmapInfo: image!.bitmapInfo.rawValue)
            context?.interpolationQuality = .high
            context?.draw(image!, in: CGRect(origin: .zero, size: size))

            guard let scaledImage = context?.makeImage() else { return nil }

            return UIImage(cgImage: scaledImage)
    }
     func clipImage() -> UIImage? {
//         let width = self.size.width
//         let height = self.size.height
//         let x = width*0.15
//         let imageWidth = (width - x*2)
         let image = self.cgImage
 
         let context = CGContext(data: nil,
                                 width: Int(size.width),
                                 height: Int(size.height),
                                 bitsPerComponent: image!.bitsPerComponent,
                                 bytesPerRow: image!.bytesPerRow,
                                 space: image?.colorSpace ?? CGColorSpace(name: CGColorSpace.sRGB)!,
                                 bitmapInfo: image!.bitmapInfo.rawValue)
         context?.interpolationQuality = .high
         context?.draw(image!, in: CGRect(origin: .zero, size: size))

         guard let scaledImage = context?.makeImage() else { return nil }

         return UIImage(cgImage: scaledImage)
         
    }
}
