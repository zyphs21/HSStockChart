# HSStockChart

[![Backers on Open Collective](https://opencollective.com/HSStockChart/backers/badge.svg)](#backers) [![Sponsors on Open Collective](https://opencollective.com/HSStockChart/sponsors/badge.svg)](#sponsors) ![iOS 9.0+](https://img.shields.io/badge/iOS-9.0%2B-blue.svg) ![Swift 5.0](https://img.shields.io/badge/Swift-5.0-orange.svg)
![MIT](https://img.shields.io/github/license/mashape/apistatus.svg)

HSStockChart 是一个绘制股票分时图、K 线图的库。支持流畅的回弹拖动，长按十字线，捏合放大缩小等功能，主要使用了 CAShapeLayer 来绘图，相比使用 Core Graphics 和重写 drawRect 的方法更高效，占用内存更小。

![](https://github.com/zyphs21/HSStockChart/blob/master/DemoScreenshot/HSStockChart.gif)

## Features

- [x] 支持绘制分时图，五日分时图，K 线图，MA 线指标，交易量柱等。
- [x] 支持横屏查看。
- [x] K 线图利用 `UIScrollView` 达到流畅的滑动查看效果。
- [x] 使用 `CAShapeLayer` 绘图，内存占用更小，效率更高。

## Explain

[中文解释](README_Chinese.md)

## Requirements

- iOS 9.0+
- Swift 5

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Installation

HSStockChart is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'HSStockChart'
```

## Author

E-mail: hansenhs21@live.com  
Blog: [myhanson.com](www.myhanson.com)  
Twitter: [Hanson,@yuanpingzhang](https://twitter.com/yuanpingzhang)  
Instagram: [hansonhs21](https://www.instagram.com/hansonhs21/)  
Facebook: [Hanson Zhang](https://www.facebook.com/zhang.yuanping.7)  

欢迎关注我的公众号：hansontalks    
![](https://github.com/zyphs21/HSStockChart/blob/master/DemoScreenshot/qrcode_for_hansontalk.jpg)

## Contributors

This project exists thanks to all the people who contribute. [[Contribute](CONTRIBUTING.md)].
<a href="graphs/contributors"><img src="https://opencollective.com/HSStockChart/contributors.svg?width=890&button=false" /></a>


## Backers

Thank you to all our backers! 🙏 [[Become a backer](https://opencollective.com/HSStockChart#backer)]

<a href="https://opencollective.com/HSStockChart#backers" target="_blank"><img src="https://opencollective.com/HSStockChart/backers.svg?width=890"></a>


## Sponsors

Support this project by becoming a sponsor. Your logo will show up here with a link to your website. [[Become a sponsor](https://opencollective.com/HSStockChart#sponsor)]

<a href="https://opencollective.com/HSStockChart/sponsor/0/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/0/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/1/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/1/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/2/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/2/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/3/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/3/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/4/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/4/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/5/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/5/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/6/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/6/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/7/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/7/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/8/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/8/avatar.svg"></a>
<a href="https://opencollective.com/HSStockChart/sponsor/9/website" target="_blank"><img src="https://opencollective.com/HSStockChart/sponsor/9/avatar.svg"></a>


## License

HSStockChart is available under the MIT license. See the LICENSE file for more info.


