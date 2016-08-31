# Dancing Glyphs Screen Saver

A screen saver for OS X that shows three ThoughtWorks glyphs dancing around.

![](https://cloud.githubusercontent.com/assets/954026/17986355/81cb49ce-6b1a-11e6-9ca7-14204b725a2c.gif)

This is work-in-progress. The basics are there, but not everything is working completely.

The screen saver uses color burn and dodge effects which are (apparently) not trivial to calculate. On the hardware I tested it on the animation runs smoothly at the target rate of 60 frames per second (fps). However, I suspect that some Mac hardware might not be powerful enough to render the animations at the target frame rate, especially when no discrete GPU is available and large glyphs are used. If the frame rate drops below 59 fps it is displayed in the bottom left corner. In that case you might want to change your settings. Or get new hardware. ;-)

Known TODOs:
- allow "random" selection for configuration options
- link size and movement when both are set to random
