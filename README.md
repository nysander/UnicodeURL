# UnicodeURL

[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnysander%2FUnicodeURL%2Fbadge%3Ftype%3Dswift-versions)](https://swiftpackageindex.com/nysander/UnicodeURL)
[![](https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fnysander%2FUnicodeURL%2Fbadge%3Ftype%3Dplatforms)](https://swiftpackageindex.com/nysander/UnicodeURL)

UnicodeURL is package providing extensions for URL which will allow it to support Internationalized domain names in URLs.

This uses code from IDN SDK from Verisign, Inc. The entire IDN SDK source package can be found at [Verisign site]( https://www.verisign.com/en_US/channel-resources/domain-registry-products/idn-sdks/index.xhtml) 

## Origin

Sources of IDNSDK used in this package are grabbed from IFUnicodeURL source code by Sean Heber from Icon Factory that can be found in [twitter/twitter-text](https://github.com/twitter/twitter-text) repository.

He has pulled out and slightly modified (to avoid compiler and analyzer warnings) the files and headers needed so that building this in Xcode is as easy as adding the UnicodeURL folder to your project.

Take note of the IDNSDK license which can be found in the IDNSDK-1.1.0.zip file. (The license is basically a BSD-like license.) 

## Contributors

Objective-C code from IFUnicodeURL package was initially transcoded to Swift by [Paweł Madej](https://github.com/nysander) with enormous help in providing fixes by [Rizwan Mohamed Ibrahim](https://github.com/rizwankce).

## License

UnicodeURL package is licensed under the MIT License (see LICENSE file) 
