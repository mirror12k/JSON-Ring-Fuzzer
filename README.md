# JSON ring fuzzer
A novel fuzzer which tests multiple implementations of JSON at the same time to find incompatability issues between them.
The construction has json implementations from PHP, javascript, Perl, Newtonsoft, and json-java, and runs them in a circle to test.

A Dockerfile and Makefile is provided for ease of testing.

The goal of this application is to find ways to bypass filters which check specific values of json before passing them onto parsers.

# Notes on breaking JSON implementations

## PHP json_decode
Put in a \xaa byte into a string, it will fail to parse the text
## Newtonsoft JObject.Parse
Put in a space into a string, it just fails...

