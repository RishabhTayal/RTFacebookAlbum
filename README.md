# RTFacebookAlbum

[![Version](http://cocoapod-badges.herokuapp.com/v/RTFacebookAlbum/badge.png)](http://cocoadocs.org/docsets/RTFacebookAlbum)
[![Platform](http://cocoapod-badges.herokuapp.com/p/RTFacebookAlbum/badge.png)](http://cocoadocs.org/docsets/RTFacebookAlbum)

Usage



To run the example project, just clone the repo and open xcodeproj file.

## Requirements

## Installation

RTFacebookAlbum is available through [CocoaPods](http://cocoapods.org), to install
it simply add the following line to your Podfile:

    pod "RTFacebookAlbum"

You need to create an app on https://developers.facebook.com/ to use this library in an actuall app and then add the Facebook app id to your app. The example project is already connected to a sample app on Facebook.

After you have created an app on Facebook you need to edit you Info.Plist. Add a key-value pair with key 'FacebookAppID' and value as the app id obtained from facebook app. Second key-value pair would be

\<key>CFBundleURLTypes\</key><br>
&nbsp;&nbsp;&nbsp;\<array><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\<dict><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\<key>CFBundleURLSchemes\</key><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\<array><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\<string>fb[YOUR APP ID]\</string><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\</array><br>
&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;\</dict><br>
&nbsp;&nbsp;&nbsp;\</array><br>


## Author

Rishabh Tayal, rtayal11@gmail.com

## License

RTFacebookAlbum is available under the MIT license. See the LICENSE file for more info.

