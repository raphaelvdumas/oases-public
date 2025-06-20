# Parallel OASES

> Gaute Hope <eg@gaute.vetsj.com>  -  2017

`PAROASES` is an extension that parallelizes the OAST and OASP/RDOASP/OASP3 modules of the
[OASES](http://technology.mit.edu/technologies/7549_oases-software-for-modeling-seismo-acoustic-propagation-in-horizontally-stratified-waveguides)
[5] acoustic wavenumber modeling package. The extensions accepts the same input
files as the original modules, and can therefore generally be used as drop-in
replacements for the original modules.

> "OASES is a general purpose computer code for modeling seismo-acoustic propagation in horizontally stratified waveguides using wavenumber integration in combination with the Direct Global Matrix solution technique [1, 2, 3]. It is basically an upgraded version of SAFARI [4]." [5]

A [MPI](https://en.wikipedia.org/wiki/Message_Passing_Interface) version is available for both modules as well.

## Installation

### Requirements

* [OASES](http://lamss.mit.edu/lamss/pmwiki/pmwiki.php?n=Site.Oases)
* Python 3
* numpy
* scipy
* [tqdm](https://github.com/tqdm/tqdm)  (optional)

> Make sure you install the dependencies for Python 3!

### Installation

`PAROASES` is installed together with `OASES` and should normally be available
after a regular build and install.

> If you are installing OASES into a non-standard location and want to use the
> PAROASES python modules make sure you add the PAROASES installation directory
> to your `PYTHONPATH`.

However, you can also add the source repository directory to your `$PATH`, or
you can symlink the executables in the root repository directory to somewhere
on your path. Or use the `setup.py` file to build and install the package
individually.

## Using the Parallel Extension modules

The modules for `OAST` and `OASP`/`RDOASP`/`OASP3` are called `paroast` and `paroasp`
respectively. The MPI variants are called `mpioast` and `mpioasp` and should be
used on systems where the job scheduler launches the MPI instances for you
(e.g. Cray). Both MPI version and regular parallel versions accept the same
arguments.

To get a list of options supply the `-h` flag:

```sh
$ paroast -h
```

jobs are launched in much the same way as in regular OASES, so if you have
created a `.dat` input file for `oast` the easiest way to run this in parallel
on a regular computer is to do:

```sh
$ paroast input.dat
```

this will split the job across the default `8` workers, run the jobs, and
collect the result in the current directory. After `paroast`/`paroasp` is done,
an `out` directory will be left over with the intermedient steps and log files
from the individual jobs.

To change the number of workers use the `-w N` argument:

```sh
$ paroast -w 16 input.dat
```

it is usually not any point in specifying more workers than there are CPUs on
the system. Note that when using `mpioast` or `mpioasp` the number of workers
are determined by the the MPI settings.

If you choose to run the individual parallelization steps manually, make sure to specify the same number of workers each time.

Specific options to each module are documented below.

### PAROAST (Transmission loss)

By default the options `-grj` are used if nothing else is specified. This runs and collects the jobs afterwards.

In particular it is also possible to use the `-m` option to move more of the
filesystem operations to the memory, this might speed up the computation if you
are on a slow disk and have enough memory.

> Note that the `Z` option (plot velocity profile) in the `.dat` file is not supported.

### PAROASP (Pulse propagation both range dependent and independent)

By default the options `-grt` are used if nothing else is specified. This runs and collects the jobs afterwards.

> The flags `-2` and `-3` indicate whether the input file is for the `rdoasp` or `oasp3` modules rather than the range-independent `oasp` module.

The final, complete, transfer functions are saved either as a `.trf` (deafult),
`.mat` or `.npz` file depending on the `--trf`, `--mat` and `--npz` flags.
These can be used with the standard `PP` or other OASES programs, or be loaded
into Matlab or Python for further processing.

> Note that there can be no blocks in the input file _after_ the frequency block.

## Other utilities

### plot_oast

This tool reads the `.plp` and `.plt` files that is produced by `OAST` or
`paroast`. Input can either be a `.dat` file for a completed job (this will
look for `.plp` and `.plt` files), or a `.mat` or `.npz` file generated by the
python package routines that can work with `OAST` jobs. See:

```sh
$ plot_oast -h
```

for more help.

## Running the tests

Included in this package is a test suite which compares the output of the sequential and
parallel versions with each other. These should be run from their reciding
directory and are found in: `paroases/oasp/test_paroasp` and `paroases/oast/test_paroast`.

The tests expect _exact_ match between the sequential and parallel versions.

## PAROASES Python Package

As part of this package numerous routines of the `paroases` package have been
split into a python package which may be of use in processing or plotting
scripts. Refer to [[#accessing-the-paroases-python-modules-optional]] below for how to install or use
this package from your python scripts.

#### Accessing the 'paroases' Python modules (optional)

If you want to make use of the `paroases` python package in your own scripts
(to e.g. read the transfer functions) either install the package using
`setup.py` or add the source repository to your `$PYTHONPATH` in `~/.profile`
or `~/.bashrc`:

```sh
export PYTHONPATH=path/to/paroases:$PYTHONPATH
```


### General

Refer to the [docstring](https://en.wikipedia.org/wiki/Docstring#Python) for the full documentation of the methods. Below is a brief overview of the modules.

#### paroases.mulplt

> This module emulates the MINDIS mulplt package by reading `.plp` and `.plt`,
> it holds one routine `read_plt ()` which takes a filename of either `.plp`,
> `.plt` or without any extension. It expects the `.plp` and `.plt` file pair
> to be present.
>
> The plot is returned as a dictionary of all the curves.

#### paroases.oasp

`ParOasp`

> Class containing the parallel implementation of `OASP`, can be executed from
> Python.

`read_trf`

> Reads a `.trf` file as created by an `OASP` module. Ported from `read_trf` in
> the original OASES package.

`write_trf`

> Writes back a `.trf` file, may be used to concatenate several `.trf` files.

`make_full_fft`

> Converts a tapered FFT to a full FFT useful for propagating a signal.

`prop_signal` and `prop_signal2`

> Propagates a source signal (time domain) through a transfer function (full
> FFT) and returns the received signal (time domain).

#### paroases.oast

`ParOast`

> Class containing the parallel implementation of `OAST`, can be executed from
> Python.

`OastJob`

> class which can read `.dat`, `.plp` and `.plt` files from a `OAST` job.

`OastJob.read_dat`

> Reads a OAST `.dat` file.

`OastJob.read_plt`

> Reads the `.plp` and `.plt` files and produces a transmission loss image from them.

`OastJob.save`

> Saves the necessary parameters from the `.dat`, `.plp` and `.plt` files as
> well as the transmission loss image.

## References

[1] Schmidt, H., & Jensen, F. B. (1985). A full wave solution for propagation in multilayered viscoelastic media with application to Gaussian beam reflection at fluid solid interfaces. The Journal of the Acoustical Society of America, 77(3), 813. http://doi.org/10.1121/1.392050

[2] Schmidt, H., & Tango, G. (1986). Efficient global matrix approach to the computation of synthetic seismograms. Geophysical Journal International. Retrieved from http://gji.oxfordjournals.org/content/84/2/331.short

[3] Jensen, F. B., Kuperman, W. A., Porter, M. B., Schmidt, H., & Bartram, J. F. (2011). Computational Ocean Acoustics. The Journal of the Acoustical Society of America (2nd ed., Vol. 97). http://doi.org/10.1121/1.411832

[4] Schmidt, H. (1988). SAFARI: Seismo-Acoustic Fast Field Algorithm for Range-Independent Environments. User’s Guide. Retrieved from http://oai.dtic.mil/oai/oai?verb=getRecord&metadataPrefix=html&identifier=ADA200581

[5] Schmidt, H. (2011). OASES Version 3.1 User Guide and Reference Manual. Retrieved from http://lamss.mit.edu/lamss/pmwiki/pmwiki.php?n=Site.Oases

