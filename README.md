# SATextField [![Carthage compatible](https://img.shields.io/badge/Carthage-compatible-4BC51D.svg?style=flat)](https://github.com/Carthage/Carthage)  ![Swift 4.0](https://img.shields.io/badge/Swift-4.0-orange.svg)
Custom textfield with placeholder that slides from inside to outside view's bounds


## Demo
![A demo gif should be here and not this text](source/SATextFieldDemo/docs/preview.gif)


## Description
Implementation of a text field with a placeholder label that floats atop the text field when focused or when text is entered.


## Installation
The easiest way to install and use is simply to include **SATextField.swift** into your project's "Compile Sources" build phase.

The project is set up as a shared framework (SATextField) to enable [Carthage](https://github.com/Carthage/Carthage) support if you don't care about taking on that complexity.

Alternatively, this can easily be added as a git submodule into your project.


## How To Use
* Implement an instance of `SATextField` (a subclass of `UITextField`) in code or via Interface Builder
	* if IB, set the custom class to `SATextField` & make sure the framework is listed in your build phases
* Set the `placeholderText` property to change the placeholder label's text
* Set the `placeholderTextColor` property to change the place holer label's default text color (defaults to gray)
* Set the `placeholderTextColorFocused` property to change the place holer label's text color when focused (defaults to white)
* Set the `slideAnimationDuration` to change how long the text slide should animate


# License
The MIT License (MIT)

Copyright (c) 2015 Stefan Arambasich

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
