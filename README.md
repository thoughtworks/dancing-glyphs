# Dancing Glyphs Screen Saver

A screen saver for OS X that shows three ThoughtWorks glyphs dancing around.

![](https://cloud.githubusercontent.com/assets/954026/17986355/81cb49ce-6b1a-11e6-9ca7-14204b725a2c.gif)

*This is work-in-progress. The screen saver is functional and all basic features work. However, while the implemention does use hardware acceleration it doesn't yet do it in a super efficient way. With large glyphs, especially the circle glyph, the animation may stutter noticeably.*

A while ago, while reading Cixin Liu's excellent novel The Three-Body Problem, I saw a shape in our brand asset library that had three of the typical ThoughtWorks glyphs superimposed, and somehow I thought, what if those three glyphs were dancing around each other like the suns in the novel? Wouldn't that make a great screen saver?

When I started implementing the idea, I decided to prototype it using a few overlayed circular paths instead of a complex physics simulation. The plan was (maybe still is) that once everything else works, I would actually try to implement the physics. In the meantime, though, I had to realise that compositing large bitmaps with a color dodge or burn effect isn't trivial with the OS X SDKs, at least not if you want to make it perform well. So, I first learned Core Animation and Core Image and, as this turned out to be not good enough, I'm now diving into the low-level Metal APIs. Depending on how long this takes, real physics will happen, or not.

Known TODOs:
- use Metal or OpenGL to avoid large data transfers to and from GPU on every frame
- fix display of frames per second to show frames actually rendered and not only frames calculated
