Squash iOS Symbolicator
=======================

This gem serves two purposes: to upload symbolication data to Squash, and to
notify Squash of new releases of the software (internally or externally).

This gem installs a `symbolicate` binary that converts a dSYM file into a format
usable for Squash, and then uploads the data to the Squash host. It also
installs a `squash_release` binary that notifies Squash of the release.

Documentation
-------------

Comprehensive documentation is written in YARD- and Markdown-formatted comments
throughout the source. To view this documentation as an HTML site, run
`rake doc`.

For an overview of the various components of Squash, see the website
documentation at https://github.com/SquareSquash/web.

Compatibility
-------------

This library is compatible with Ruby 1.8.6 and later, including Ruby Enterprise
Edition.

Requirements
------------

This gem requires the `json` gem (http://rubygems.org/gems/json). You can use
any JSON gem that conforms to the typical standard
(`require 'json'; object.to_json`).

This gem uses the `plist` gem to parse your Info.plist file. The property list
must be in XML, not binary, format.

This gem uses `dwarfdump` to perform its symbolication. You'll therefore need
the Xcode Command Line tools installed on the machine that will be performing
the symbolication upload.

Usage
-----

### Uploading Symbolication Data

This gem installs a command-line binary named `symbolicate`. It is called in the
following format:

````
symbolicate [options]
````

Example: `symbolicate --host https://squash.mycompany.com`

This binary is intended to be used as part of your release process. In Xcode,
you can add a build script that invokes this binary. Little configuration is
needed: Xcode sets a number of environment variables related to the build, and
`symbolicate` uses these by default to find the data it needs. You can customize
the script's options as needed to suit your specific toolchain, though.

An example "Run Script" phase for a build might look like this, assuming you had
the gem installed in a gemset using RVM:

```` sh
/Users/someone/.rvm/bin/rvm 1.8.7@squash do /Users/someone/.rvm/gems/ruby-1.8.7-p370@squash/bin/symbolicate
````

For documentation on `symbolicate`'s command-line options, run
`symbolicate --help.`

### Release Notification

This gem installs a command-line binary named `squash_release`. It is called in
the following format:

````
squash_release [options] <API key> <environment>
````

Example: `squash_release --build 1138 a9232f94-6c2d-45ae-8f9e-9add5bd7ff35 internal_beta`

This binary is intended to be used as part of your release process, similar to
`symbolicate` (see above). Like `symbolicate`, sensible defaults are provided
for all command line switches.

For documentation on `squash_release`'s command-line options, run
`squash_release --help`.

Data Transmission
-----------------

Symbolication and release data is transmitted to Squash using JSON-over-HTTPS. A
default API endpoint is pre-configured, though you can always set your own (see
`symbolicate --help` or `squash_release --help`).

By default, `Net::HTTP` is used to transmit errors to the API server. If you
would prefer to use your own HTTP library, you can override the
{SquashUploader#http_post} method.

Use as a Library
----------------

In addition to using the symbolication with Squash, you can also use the gem as
a library, to perform symbolication for your own purposes (even unrelated to
Squash). See the {Symbolicator} class documentation for more information. To
use the gem, include `require 'squash/symbolicator'` in your code.
