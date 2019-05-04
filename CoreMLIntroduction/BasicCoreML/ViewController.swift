

import UIKit
import CoreML

class ViewController: UIViewController {
    
    @IBOutlet weak var out: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    @IBAction func imageTapped(_ sender: UITapGestureRecognizer) {
        let imageView = sender.view as? UIImageView
        
        if let imageToAnalyse = imageView?.image {
            if let outImg = process(forImage: imageToAnalyse) {
                out.image = outImg
            }
        }
    }
    
    func process (forImage inImage:UIImage) -> UIImage? {
        
        let size = CGSize(width: 512, height: 512)
        let mlOut = try? MLMultiArray(shape: [1, size.height, size.width] as [NSNumber], dataType: .float32)
        let newImage = getSinglePlaneImage(inBuffer: mlOut!, width: Int(size.width), height: Int(size.height))
        
        return newImage
    }
    
    func getSinglePlaneImage(inBuffer: MLMultiArray, width: Int, height: Int) -> UIImage {
        
        //simulating pixels from MLMultiArray
        //...
        let pixelValues: [UInt8] = Array(repeating: 0, count: 1*512*512)
        
        let bitsPerComponent = 8
        let bytesPerPixel = 1
        let bitsPerPixel = bytesPerPixel * 8
        let bytesPerRow = bytesPerPixel * width
        let totalBytes = height * bytesPerRow
        
        let imageRef = pixelValues.withUnsafeBytes({bytes -> CGImage? in
            var imageRef: CGImage?
            let colorSpaceRef = CGColorSpaceCreateDeviceGray()
            let bitmapInfo: CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)
            
            let data = bytes.baseAddress!.assumingMemoryBound(to: UInt8.self)
            let releaseData: CGDataProviderReleaseDataCallback = {_,_,_ in }
            
            if let providerRef = CGDataProvider(dataInfo: nil, data: data, size: totalBytes, releaseData: releaseData) {
                imageRef = CGImage(width: width,
                                   height: height,
                                   bitsPerComponent: bitsPerComponent,
                                   bitsPerPixel: bitsPerPixel,
                                   bytesPerRow: bytesPerRow,
                                   space: colorSpaceRef,
                                   bitmapInfo: bitmapInfo,
                                   provider: providerRef,
                                   decode: nil,
                                   shouldInterpolate: false,
                                   intent: .defaultIntent)
            }
            
            
            return imageRef
        })
        
        let newImage = UIImage(cgImage: imageRef!)
        
        return newImage
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
