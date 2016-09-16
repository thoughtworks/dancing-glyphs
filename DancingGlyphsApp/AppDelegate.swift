
import Cocoa
import ScreenSaver

@NSApplicationMain
class AppDelegate: NSObject
{
    @IBOutlet weak var window: NSWindow!
    
    var view: ScreenSaverView!
 
    func setupAndStartAnimation()
    {
        view = DancingGlyphsView(frame: window.contentView!.frame, isPreview: false)
        view.autoresizingMask = [NSAutoresizingMaskOptions.viewWidthSizable, NSAutoresizingMaskOptions.viewHeightSizable]
        window.contentView!.autoresizesSubviews = true
        window.contentView!.addSubview(view)
        window.backingType = DancingGlyphsView.backingStoreType()
        view.startAnimation()
    }
    
    func animateOneFrame()
    {
        let context = window.graphicsContext
        NSGraphicsContext.setCurrent(context)
        view.animateOneFrame()
        context?.flushGraphics()
    }
    
    @IBAction func showPreferences(_ sender: NSObject!)
    {
        window.beginSheet(view.configureSheet()!, completionHandler: nil)
    }

}


extension AppDelegate: NSApplicationDelegate
{
    func applicationDidFinishLaunching(_ notification: Notification)
    {
        setupAndStartAnimation()
        Timer.scheduledTimer(timeInterval: view.animationTimeInterval, target: self, selector: #selector(animateOneFrame), userInfo: nil, repeats: true)
    }
}


extension AppDelegate: NSWindowDelegate
{
    func windowWillClose(_ notification: Notification)
    {
        NSApplication.shared().terminate(window)
    }
    
    func windowDidResize(_ notification: Notification)
    {
    }
    
    func windowDidEndSheet(_ notification: Notification)
    {
        view.stopAnimation()
        view.startAnimation()
    }
}
