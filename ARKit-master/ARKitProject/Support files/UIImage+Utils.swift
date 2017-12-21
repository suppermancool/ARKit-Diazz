//
//  UIImage+Utils.swift
//  ARKitDraw
//
//  Created by dat on 12/9/17.
//  Copyright © 2017 Felix Lapalme. All rights reserved.
//

import UIKit

public struct PixelData {
    var a:UInt8 = 255
    var r:UInt8
    var g:UInt8
    var b:UInt8
}

private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedFirst.rawValue)

extension UIImage {
    func scaleAndSquareImage(_ scale: Float) -> UIImage {
        var image = resizeImage(scale: CGFloat(scale))
        image = image.imageByCroppingImage(size: CGSize(width: image.size.width, height: image.size.width))
        return image
    }
    
    func printPixel() {
        let max:Double = getMaxPixelColor()
        print("max pixel \(max)")
    }
    
    //On the top of your swift
    func getMaxPixelColor() -> Double {
        let pixelData = ((self.cgImage!).dataProvider!).data
        let data: UnsafePointer<UInt8> = CFDataGetBytePtr(pixelData)
        
        var max:Double = 0
        for row in 0..<Int(self.size.height) {
            for col in 0..<Int(self.size.width) {
                let pixelInfo: Int = ((Int(self.size.width) * row) + col) * 4
                let r = Double(data[pixelInfo])
                if r > max {
                    max = r
                }
                //        let g = CGFloat(data[pixelInfo+1])
                //        let b = CGFloat(data[pixelInfo+2])
                //        print("r \(r), g \(g), b \(b)")
            }
        }
        return max
    }
    
    func resizeImage(scale: CGFloat) -> UIImage {

        let newHeight = self.size.height * scale
        let newWidth = self.size.width * scale
        
        UIGraphicsBeginImageContext(CGSize(width: newWidth, height: newHeight))
        self.draw(in: CGRect(x: 0, y: 0, width: newWidth, height: newHeight))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage!
    }
    
    func imageByCroppingImage(size: CGSize) -> UIImage {
        let newCropWidth, newCropHeight: Double
        
        //=== To crop more efficently =====//
        if self.size.width < self.size.height {
            if self.size.width < size.width {
                newCropWidth = Double(size.width);
            } else {
                newCropWidth = Double(self.size.width);
            }
            newCropHeight = (newCropWidth * Double(size.height))/Double(size.width);
        } else {
            if self.size.height < size.height {
                newCropHeight = Double(size.height);
            } else {
                newCropHeight = Double(self.size.height);
            }
            newCropWidth = (newCropHeight * Double(size.width))/Double(size.height);
        }
        //==============================//
        let x: Double = Double(self.size.width)/2.0 - newCropWidth/2.0;
        let y:Double = Double(self.size.height)/2.0 - newCropHeight/2.0;
        
        let cropRect: CGRect = CGRect(x: x, y: y, width: newCropWidth, height: newCropHeight)
        let imageRef = self.cgImage!.cropping(to: cropRect)
        let cropped:UIImage = UIImage(cgImage: imageRef!)
        return cropped
    }
    
    class func getPos(width: Int, pos: Int) -> CGPoint {
        return CGPoint(x: pos % width, y: pos / width)
    }
    
    class func getPos(width: Int, pos: CGPoint) -> Int {
        return Int(pos.y) * width + Int(pos.x)
    }
    
    class func getNeighbor(width: Int, height: Int, pos: Int, max: Int, depths: inout [Int], isChecked: inout [Bool]) -> [Int] {
        let current = getPos(width: width, pos: pos)
        let x = Int(current.x)
        let y = Int(current.y)
        let up = y - 1
        let down = y + 1
        let left = x - 1
        let right = x + 1
        var neighbor = [Int]()
        let checkPos = {
            (pos2d: CGPoint, isChecked: inout [Bool], depths: inout [Int]) in
            
            let delta = CGFloat(width / 8)
            let left = delta
            let right = CGFloat(width) - delta
            let top = delta
            let bottom = CGFloat(height) - delta
            let pos = getPos(width: width, pos: pos2d)
            
            if depths[pos] < max/2 { depths[pos] = 0 }
            if pos2d.x < left || pos2d.x > right || pos2d.y < top || pos2d.y > bottom {
                depths[pos] = 0
            }
            if depths[pos] > 0 && !isChecked[pos] { neighbor.append(pos) }
            isChecked[pos] = true
        }
        if up >= 0 {
            if left >= 0 { checkPos(CGPoint(x: left, y: up), &isChecked, &depths) }
            checkPos(CGPoint(x: x, y: up), &isChecked, &depths)
            if right < width { checkPos(CGPoint(x: right, y: up), &isChecked, &depths) }
        }
        if down < height {
            if left >= 0 { checkPos(CGPoint(x: left, y: down), &isChecked, &depths) }
            checkPos(CGPoint(x: x, y: down), &isChecked, &depths)
            if right < width { checkPos(CGPoint(x: right, y: down), &isChecked, &depths) }
        }
        if left >= 0 { checkPos(CGPoint(x: left, y: y), &isChecked, &depths) }
        if right < width { checkPos(CGPoint(x: right, y: y), &isChecked, &depths) }
        return neighbor
    }
    
    class func reduceNoises(width: Int, height: Int, max: Int, depths: inout [Int]) {
        var curPos = 0
        let length = depths.count
        var isCheckPixels = [Bool](repeating: false, count: length)
        while curPos < length {
            var neighborQueue = [Int]()
            neighborQueue.append(curPos)
            var neighborCheck = [Int]()
            while neighborQueue.count > 0 {
                let pos = neighborQueue.popLast()!
                let neighbor = getNeighbor(width: width, height: height, pos: pos, max: max, depths: &depths, isChecked: &isCheckPixels)
                neighborCheck.append(contentsOf: neighbor)
                neighborQueue.append(contentsOf: neighbor)
            }
            if neighborCheck.count < 150 {
                for i in 0..<neighborCheck.count {
                    depths[neighborCheck[i]] = 0
                }
            }
            curPos += 2
        }
    }
    
    class func renderGray(width: Int, height: Int, max: Int, depths:[Int]) -> UIImage? {
        let emptyPixel = PixelData(a: 255, r: 0, g: 0, b: 0)
        let length = Int(width * height)
        var pixelData = [PixelData](repeating: emptyPixel, count: length)
        for i in 0..<length {
            let value = (depths[i] > 255) ? 255 : depths[i]
            pixelData[i].r = UInt8(value)
            pixelData[i].g = UInt8(value)
            pixelData[i].b = UInt8(value)
        }
        let outputImage = imageFromARGB32Bitmap(width: width, height: height, pixels: pixelData)
        return outputImage
    }
    
    class func imageFromARGB32Bitmap(width:Int, height:Int, pixels:[PixelData] ) -> UIImage? {
        let bitsPerComponent:Int = 8
        let bitsPerPixel:Int = 32
        
        assert(pixels.count == Int(width * height))
        
        var data = pixels // Copy to mutable []
        guard let providerRef = CGDataProvider( data: NSData(bytes: &data, length: data.count * MemoryLayout<PixelData>.size)) else {
            return nil
        }
        
        let cgim = CGImage(
            width: width,
            height: height,
            bitsPerComponent: bitsPerComponent,
            bitsPerPixel: bitsPerPixel,
            bytesPerRow: width * MemoryLayout<PixelData>.size,
            space: rgbColorSpace,
            bitmapInfo: bitmapInfo,
            provider: providerRef,
            decode: nil,
            shouldInterpolate: true,
            intent: .defaultIntent
        )
        return UIImage(cgImage: cgim!)
    }
    
}
