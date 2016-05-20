# DDF cons3rt software asset

[![Build Status](https://travis-ci.org/oconnormi/cons3rt-ddf-linux.svg?branch=master)](https://travis-ci.org/oconnormi/cons3rt-ddf-linux)

A [cons3rt](https://www.cons3rt.com) software asset for installing the [Distributed Data Framework](codice.org/ddf) (DDF)

# Building
The project is assembled using GNU Make

*Note: grip is required to render markdown documentation*

## To create the distribution assembly
```
make
```

_Distributions will be located under `build/distributions`_

## To run the tests

*Note: requires docker*

```
make test
```
