/*
 *  Copyright 2016 Erik Doernenburg
 *
 *  Licensed under the Apache License, Version 2.0 (the "License"); you may
 *  not use these files except in compliance with the License. You may obtain
 *  a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing, software
 *  distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
 *  WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
 *  License for the specific language governing permissions and limitations
 *  under the License.
 */
import Cocoa

class Logo
{
    var image: NSImage!
    
    init()
    {
        let url = Bundle(for: Logo.self).url(forResource: "Logo", withExtension: "png")!
        image = NSImage(contentsOf: url)!
    }
    
    func makeBitmap(width: CGFloat) -> NSBitmapImageRep
    {
        let imageRep = NSBitmapImageRep(bitmapDataPlanes: nil, pixelsWide: Int(width), pixelsHigh: Int(width/image.size.width*image.size.height), bitsPerSample: 8, samplesPerPixel: 4, hasAlpha: true, isPlanar: false, colorSpaceName: NSCalibratedRGBColorSpace, bytesPerRow: Int(width)*4, bitsPerPixel:32)!
        
        NSGraphicsContext.saveGraphicsState()
        NSGraphicsContext.setCurrent(NSGraphicsContext(bitmapImageRep: imageRep))
        
        image.draw(in: NSMakeRect(0, 0, imageRep.size.width, imageRep.size.height))
        
        NSGraphicsContext.restoreGraphicsState()
        
        return imageRep
    }

}
