
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
        view.autoresizingMask = [NSAutoresizingMaskOptions.ViewWidthSizable, NSAutoresizingMaskOptions.ViewHeightSizable]
        window.contentView!.autoresizesSubviews = true
        window.contentView!.addSubview(view)
        view.startAnimation()
    }
    
    func animateOneFrame()
    {
        let context = window.graphicsContext
        NSGraphicsContext.setCurrentContext(context)
        view.animateOneFrame()
        context?.flushGraphics()
    }
    
    @IBAction func showPreferences(sender: NSObject!)
    {
        window.beginSheet(view.configureSheet()!, completionHandler: nil)
    }
    

}


extension AppDelegate: NSApplicationDelegate
{
    func applicationDidFinishLaunching(notification: NSNotification)
    {
        setupAndStartAnimation()
        NSTimer.scheduledTimerWithTimeInterval(view.animationTimeInterval, target: self, selector: #selector(animateOneFrame), userInfo: nil, repeats: true)
    }
}


extension AppDelegate: NSWindowDelegate
{
    func windowWillClose(notification: NSNotification)
    {
        NSApplication.sharedApplication().terminate(window)
    }
    
    func windowDidResize(notification: NSNotification)
    {
    }
}
