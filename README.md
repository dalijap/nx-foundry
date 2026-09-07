# NX Foundry

## Overview

NX Foundry is a modern, versatile, cross-platform unit testing and mocking
framework for Delphi, supporting versions from Delphi 7 to the latest releases.
Simple to use and easily extendable, NX Foundry provides support for console and
GUI runners for both VCL and FMX frameworks, as well as TestInsight. Its test
verification system is also compatible with DUnit and can be used as a DUnit
extension for a smoother, more gradual migration of existing DUnit tests.

**Note:** This is a pre-release version. Not all planned features have been
implemented yet, and APIs and behaviors are subject to change. 

## Features

+ Unit testing framework
+ Mocking framework (to be developed)
+ Cross-platform
+ Support for old, pre-Unicode Delphi versions
+ Support for new features and new Delphi versions
+ Console and GUI (VCL and FMX) engines 
+ Support for TestInsight
+ Tests are derived from the base `TNxTestCase` class or its alias `TTestCase`
+ It is also possible to register test cases using classes which implement
  `INxTest` or `INxTestSuite` interfaces
+ Attribute based testing (to be developed)
+ Test verification through overloaded, standalone `Expect` functions and
  accompanying classes which can also be used with the DUnit testing framework
  - Being decoupled from the test case class gives more flexibility for adding
    custom extensions which can follow the same naming convention
  - Based on a fluent interface where the first call in a sequence takes only
    single parameter — the actual value; this approach avoids compiler ambiguities
    which can more easily occur when more parameters exist in an overload

## Supported Delphi Versions and Platforms

Supports Delphi 7 and later, and all platforms using a classic, non-ARC compiler. 

Tested on the following versions:

+ D7
+ XE4
+ 10.3 Rio
+ 10.4 Sydney
+ 11 Alexandria
+ 12 Athens
+ 13 Florence

---

**Please support my work** 

https://www.paypal.com/ncp/payment/CVVVLKZD9246J

---

[https://dalija.prasnikar.info](https://dalija.prasnikar.info)
