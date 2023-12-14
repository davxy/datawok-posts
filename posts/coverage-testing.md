+++
title = "C/C++ Code Coverage Testing"
date = "2018-05-14"
tags = ["programming","tooling"]
+++

Coverage testing measures the effectiveness of test suites by determining the
code coverage. It identifies areas of the code that haven't been executed,
enabling to improve test quality and enhance software reliability.


## Coverage information files

To build object files capable to produce coverage data the `gcc` `coverage`
option should be used.

Compilation:

    $ gcc --coverage -c test.c

Linking

    $ gcc --coverage test.o -o test

The `--coverage` option is used to compile and link code instrumented for
coverage analysis and is synonym for `-fprofile-arcs -ftest-coverage` (when
compiling) and `-lgcov` (when linking).

When compiling, this switch produces, along with the object file, a `.gcno` file
containing the information to reconstruct the basic block graphs and assign
source line numbers to blocks. This file is the product of the `-ftest-coverage`
compiler switch.

When executing a file compiled/linked with the `coverage` options a `gcda` file
containing the effective program flow recordings is produced. This file is the
product of the `-fprofile-arcs` switch.

Excerpt from the `gcc` online manual:

    -fprofile-arcs
        
        Add code so that program flow arcs are instrumented. During execution
        the program records how many times each branch and call is executed and
        how many times it is taken or returns. 

        When the compiled program exits it saves this data to a file called
        auxname.gcda for each source file. The data may be used for
        profile-directed optimizations (-fbranch-probabilities), or for test
        coverage analysis (-ftest-coverage). Each object file’s auxname is
        generated from the name of the output file, if explicitly specified and
        it is not the final executable, otherwise it is the basename of the
        source file. In both cases any suffix is removed (e.g. foo.gcda for
        input file dir/foo.c, or dir/foo.gcda for output file specified as -o
        dir/foo.o). 

    -ftest-coverage

        Produce a notes file that the gcov code-coverage utility (see gcov—a
        Test Coverage Program) can use to show program coverage. Each source
        file’s note file is called auxname.gcno. Refer to the -fprofile-arcs
        option above for a description of auxname and instructions on how to
        generate test coverage data. Coverage data matches the source files
        more closely if you do not optimize.


## GCOV

*GCOV* is a GNU tool which provides information about what parts of a program
are actually executed (i.e. "covered") while running a particular test case.

This tool usually comes bundled with the *GCC* toolchain.

Assuming that we've compiled and linked a source file with the `gcc`
`--coverage` switch, a specific source file coverage report is generated with
the following command:

    $ gcov test.o

The command will automatically use the `test.gcda` and `test.gcno` files in the
directory of the analyzed file to generate a `test.c.gcov` file and to print
coverage stats to the stdout.

The `.gcov` file is a human-readable file and contains the analyzed file sources
plus coverage information (i.e. if a line has been covered and for how many
times).

**NOTE**

If we run the executable multiple times then the new execution coverage
information is appended to the previous `gcda` file. This allows coverage 
statistics when the execution path is not systematically the same (e.g. this
may happen if the `malloc` is involved).


## LCOV

*LCOV* is an extension of *GCOV*, The extension consists of a set of *Perl*
scripts which build on the textual *GCOV* output to implement the following
enhanced functionality:

- *HTML* based output: coverage rates are additionally indicated using bar
  graphs and specific colors.
- Support for large projects: overview pages allow quick browsing of
  coverage data by providing three levels of detail: directory view,
  file view and source code view.

### Basic usage

The most straightforward way to use *LCOV* is to first run it to zero all the
counters (i.e. delete the `gcda` files)

    $ lcov -z -d <gcda-files-dir>

Next run the executable compiled to produce `gcda` files (i.e. the same run
for `lcov`).

    $ lcov -c -d <gcda-files-dir> -o cover.info

*LCOV* will produce coverage information only for the program object files that
has an associated `gcda` file. That is, object files that were linked to the
final executable.

To produce coverage information for **all** the object files, that were
compiled with the `--coverage` switch, even if they were not linked to the
program we must use the `-i` option (capture initial *zero coverage* data).

The flag will generate coverage information (with zero coverage) for every
object file having an associated `gcno` file.

First clean up `gcda` files

    $ lcov -z -d <gcda-files-dir>

Run the executable to produce the `gcda` files.

Scan for `gcno` file to produce coverage for all the object files within the
project (even if are not linked).

    $ lcov -c -i -d <gcda-files-dir> -o base.info

Generate effective coverage data as usual and save it in a different info file.

    $ lcov -c -d <gcda-files-dir> -o cover.info

Merge the two files into a single, complete, coverage file

    $ lcov -a base.info -a cover.info -o allcover.info


### HTML generation

The `info` files alone are not meant for human consumption.

You can generate a nice *HTML* version of the coverage data by using the
`genhtml` tool

    $ genhtml cover.info [-o outdir]


## GCOVR

Inspired by the *Python* `coverage.py` package, the *GCOVR* command provides a
utility for running the *GCOV* tool and summarizing code coverage results.

Further, *GCOVR* can be viewed as a command-line alternative of the *LCOV*
utility, which runs *GCOV* and generates an *HTML* output.

The `gcovr` command can produce different kinds of coverage reports:

- default: compact human-readable summaries
- `--xml`: machine-readable *XML* reports in *Cobertura* format
- `--html`: *HTML* summaries
- `--html-details`: *HTML* report with annotated source files

Usage is pretty similar to the other tools.

If you want to quickly display a concise coverage report on the command line,
*GCOVR* is the ideal tool since you can issue the command on the project root
without issuing it against every file like direct usage of *GCOV* (without
recurring to `xargs`).


## COVERALLS

If your project is versioned by `git` and hosted on `github.com` then
`coveralls.io` offers a free nice view of coverage data.

Inspired from `python-coveralls`, it uploads the coverage report of C/C++
project to `coveralls.io`.

Installation

    $ pip install cpp-coveralls

Quick usage:
- build the project with coverage support (as usual)
- Run the tests
- Run coveralls

Popular run options

    $ coveralls -b . --exclude <test-dir> --gcov-options '\-lp'

To be published to the `coveralls.io` website, the above commands can be run
from a `docker` image started by the *Travis CI* service.
