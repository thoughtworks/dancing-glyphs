# Dancing Glyphs Screen Saver

A screen saver for OS X that shows three ThoughtWorks glyphs dancing around.

![](https://cloud.githubusercontent.com/assets/954026/17986355/81cb49ce-6b1a-11e6-9ca7-14204b725a2c.gif)

*This is work-in-progress. The basics are there, but not everything works as intended.*

The screen saver uses color burn and dodge effects on large bitmaps. It does use hardware acceleration but it doesn't yet do it in a super efficient way. With large glyphs, especially the circle glyph, the animation may stutter noticeably.

Known TODOs:
- use Metal or OpenGL to avoid large data transfers to and from GPU on every frame
- fix display of frames per second to show frames actually rendered and not only frames calculated
- allow "random" selection for configuration options
- link size and movement when both are set to random
