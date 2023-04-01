# UnityShaderDemo
主要了解一下各个效果的实现原理，如果要在正式项目中进行使用，并且不影响在Unity中的各种效果（如mask，clip）等，需要将效果的实现逻辑移植到Unity默认的Shader文件中。

在学习过程中发现，实现效果难的部分不是代码，而是实现效果的实现逻辑。了解了效果的实现逻辑，抽象成数学模型，即可使用代码实现。

## ImageGray 图像置灰
主要在片元着色器中进行处理，将当前像素的rgb色值设置为一样的数值，即可得到灰度图。但具体数值的计算可以使用以下方法试下。一般使用加权平均算法进行处理，因为这样得到的图像细节更多。
* 平均值法：`(r + g + b) / 3`
* 分量法：`r` 或 `g` 或 `b`
* 最大值法：`max(r, g, b)`
* 加权平均法：`r * wr + g *wg + b * wb`

## ImageGrayWithMask 图像置灰，带mask
只是给置灰加了一个Unity的Mask支持，设置模板缓冲参数即可实现。

## ImageGrayPart 图像盖住的屏幕区域置灰
使用GrabPass函数捕捉屏幕图像，再对捕捉到的图像进行灰度处理。

## ImageAlphaZWriteOn 不渲染透明像素遮挡住的像素
用一个pass将透明像素的深度进行写入，不输出任何颜色，有了深度写入就会自动打开深度测试，在深度测试阶段就会将该片元舍弃。

## ImageEdgeDetection 图像边缘检测
使用Sobel算子计算相邻像素的梯度值，梯度度越大，越有可能是边缘。将当前的像素颜色和边缘颜色利用梯度值进行插值计算。

## ImageGaussianBlur 对单个图像进行高斯模糊处理
在图像渲染前获取到当前图像的texture，并对texture进行降采样处理，最后进行多次高斯模糊迭代，与高斯模糊后处理的逻辑相同，只是处理对象不同。

## ImagePixel 对单个图像进行像素化处理
将图像分成多个块，每个块中所有像素的颜色取当前块中心点像素的颜色值，即可实现像素效果。块的尺寸越大，像素化效果越明显。

## ImagePart 只显示图像的某一部分
这是在做径向模糊时意外做出的效果，主要原理就是以某个点为中心画一个圆，并且只显示圆内的内容，超出部分不显示。根据点与圆心的距离对当前像素颜色和黑色进行插值计算。

## FrameAnimation 帧动画
在片元着色器中进行完成，通过内置时间参数_Time.y计算当前要采样的区域，最后实现帧动画。

## FrostedGlass 毛玻璃效果
毛玻璃的实现使用了多种方式，如下：
* 使用`GrabPass`对当前屏幕进行采样，再进行高斯模糊处理或者`DualKawase`模糊处理，迭代的次数越多，模糊效果越好。迭代次数包含多次`GrabPass`和模糊迭代，所以性能消耗有点大。
* 使用`CommandBuffer`，在渲染命令队列里插入处理命令，对已渲染的元素进行高斯模糊处理，将处理后的图片使用`SetGlobalTexture`函数传入到Shader。将要模糊的区域坐标转换为屏幕坐标，使用转换后的坐标对前一步生成的模糊图片进行采样。相比于`GrabPass`，此方法抓取屏幕的次数比较少，因此性能比GrabPass好。

# 后处理篇
## BrightnessSaturationContrast 修改屏幕的亮度，饱和度，对比度
通过以下公式对输出像素的亮度，饱和度和对比度进行修改：
* 亮度：`rgb * brightness`，brightness越大，亮度越高
* 饱和度：`lerp(luminance, rgb, saturation)`，首先需要计算出当前像素的亮度luminance，即饱和度为0的值，再对亮度和当前色值进行插值计算
* 对比度：`lerp(sat, rgb, contrast)`，首先设置一个对比度为0的颜色值，然后再对该值和当前像素颜色进行插值

## GaussianBlur 高斯模糊
使用高斯卷积核计算像素的加权值，最后相加得到当前像素颜色值
* 使用卷积核对像素进行计算，卷积核越大，模糊效果越好
* 迭代次数越多，效果越好，但次数越多，性能消耗也会越大
* 在使用材质对图像进行处理前，先对图像进行降采样处理，例如1000x1000的图缩小为200x200的图，这样不仅可以减少计算量，而且还可以得到更好的效果。但采样过小容易出现像素块

## Magnifier 放大镜
沿某个方向对当前像素进行放大，并限制缩放范围为圆形。为了得到更好的过度效果，在圆的边缘设置一个范围，进行stepsmooth处理。

## RadialBlur 径向模糊
* 确定径向模糊的中心点，计算采样像素与中心点的距离和方向，`center - i.uv`
* 根据距离确定偏移程度，距离越大，偏移程度也越大，`i.uv + dir * xxx`
* 将采样点像素颜色进行加权和
* 最后将计算后的颜色与原颜色进行插值，`lerp(col, blurCol, saturate(_BlurIntensity * dist))`，BlurIntensity可控制径向模糊的范围
* 模糊程度同样取决与迭代次数和采样值，downSample值越大，像素计算次数越少，模糊效果越好
* degree控制偏移程度，blurIntensity控制径向模糊范围，downSample控制采样，iterations控制迭代次数

## DepthOfField 景深效果
相机渲染出的深度纹理和相机后处理出的高斯模糊图像进行插值，得到景深效果
* 打开相机的深度图输出设置
* 在OnRenderImage里对图像进行高斯模糊
* 将模糊后的图与原图根据深度值和焦距进行插值
* 2D元素同样也实现景深效果，由于渲染深度纹理需要在不透明渲染队列且有投影Pass，故对原`Sprites-Default.shader`进行了一部份修改，想要实现景深效果的2DSprite图像需要使用此Shader

