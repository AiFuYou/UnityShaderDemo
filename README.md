# UnityShaderDemo
主要了解一下各个效果的实现原理，如果要在正式项目中进行使用，并且不影响在Unity中的各种效果（如mask，clip）等，需要将效果的实现逻辑移植到Unity默认的Shader文件中。

在学习过程中发现，实现效果难的部分不是代码，而是实现效果的实现逻辑。了解了效果的实现逻辑，抽象成数学模型，即可使用代码实现。

## `ImageGray` 图像置灰
主要在片元着色器中进行处理，将当前像素的rgb色值设置为一样的数值，即可得到灰度图。但具体数值的计算可以使用以下方法试下。一般使用加权平均算法进行处理，因为这样得到的图像细节更多。
* 平均值法：`gray = (r + g + b) / 3`
* 分量法：`gray = r` 或 `gray = g` 或 `gray = b`
* 最大值法：`gray = max(r, g, b)`
* 加权平均法：`r * wr + g *wg + b * wb`

## `ImageGrayWithMask` 图像置灰，带mask
只是给置灰加了一个Unity的Mask支持，设置模板缓冲参数即可实现

## `ImageGrayPart` 图像盖住的屏幕区域置灰
使用GrabPass函数捕捉屏幕图像，再对捕捉到的图像进行灰度处理

## `FrameAnimation` 帧动画
在片元着色器中进行完成，通过内置时间参数_Time.y计算当前要采样的区域，最后实现帧动画

## `FrostedGlass` 毛玻璃效果
使用GrabPass对当前屏幕进行采样，再进行高斯模糊处理或者DualKawase模糊处理，模糊效果越好，需要迭代的次数越多，所以性能消耗有点大


# 后处理篇
## BrightnessSaturationContrast 修改屏幕的亮度，饱和度，对比度
* 亮度：`rgb * brightness`，brightness越大，亮度越高
* 饱和度：`lerp(luminance, rgb, saturation)`，首先需要计算出当前像素的亮度luminance，即饱和度为0的值，再对亮度和当前色值进行插值计算
* 对比度：`lerp(sat, rgb, contrast)`，首先设置一个对比度为0的颜色值，然后再对该值和当前像素颜色进行插值

