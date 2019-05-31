readcern
=======================================

Overview
---------------------------------------
This is a utility package for reading columnar file formats found
at CERN. It provides support for reading over the XRootD protocol.

Installation
---------------------------------------
Currently `readcern` is only on GitHub.
```r
devtools::install_github("rmatev/readcern")
```

Usage
---------------------------------------
### Reading over XRootD
```r
connection <- readcern::xrd('root://eosuser.cern.ch//eos/user/r/rmatev/readcern/README')
readr::read_file(connection)
```
Compressed files (`.gz`, `.bz2` and `.xz`) are also supported.

### Reading data from the accelerator logging database
```r
read_acclogging_csv(readcern_example('Summary_4691_B1.HYB.CSV.gz'))
```

### Reading `PVSSExport` data
`PVSSExport` is an LHCb-specific tool that writes out data in csv format.
A thin wrapper arround `read_csv` is provided to read them:
```r
readcern::read_pvss_export('root://eosuser.cern.ch//eos/user/r/rmatev/readcern/pvss.csv')
```
