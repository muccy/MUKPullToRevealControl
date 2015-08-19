# MUKPullToRevealControl

[![CI Status](http://img.shields.io/travis/muccy/MUKPullToRevealControl.svg?style=flat)](https://travis-ci.org/muccy/MUKPullToRevealControl)
[![Version](https://img.shields.io/cocoapods/v/MUKPullToRevealControl.svg?style=flat)](http://cocoadocs.org/docsets/MUKPullToRevealControl)
[![License](https://img.shields.io/cocoapods/l/MUKPullToRevealControl.svg?style=flat)](http://cocoadocs.org/docsets/MUKPullToRevealControl)
[![Platform](https://img.shields.io/cocoapods/p/MUKPullToRevealControl.svg?style=flat)](http://cocoadocs.org/docsets/MUKPullToRevealControl)

`MUKPullToRevealControl`, when added to a UIScrollView instance, places itself at top and can be pulled to be revealed. When user has revealed the control, the control fires its `UIControlEventValueChanged` event.
It could be subclassed to achieve a pull to refresh control: `MUKCirclePullToRefreshControl` is an example of that.

![Demo](http://cl.ly/image/2K3w1L060n2k/Senza_titolo.gif)

## Usage

````objective-c
MUKPullToRevealControl *pullToRevealControl = [[MUKPullToRevealControl alloc] init];
[pullToRevealControl addTarget:self action:@selector(pullToRevealControlTriggered:) forControlEvents:UIControlEventValueChanged];
[scrollView addSubview:pullToRevealControl];
````

## Requirements

* iOS 7 SDK.
* Minimum deployment target: iOS 7.

## Installation

`MUKPullToRevealControl` is available through [CocoaPods](http://cocoapods.org). To install
it, simply add the following line to your Podfile:

    pod "MUKPullToRevealControl"

## Author

Marco Muccinelli, muccymac@gmail.com

## License

`MUKPullToRevealControl` is available under the MIT license. See the LICENSE file for more info.
