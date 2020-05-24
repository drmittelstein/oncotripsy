# Oncotripsy

This repository includes scripts that were used to simulate the impact of cavitating bubbles in amplifying incident ultrasound waves on nearby cells.  

### Software Prerequisites

This system requires baseline MATLAB, it was programmed on 2019, but may run on earlier versions.

## How to Use

This repo uses the Keller-Miksis model to simulate the pressure amplification of an incident ultrasound signal as a function of initial bubble radius and distance from center of cavitating bubble leading to the generation of the following image:

![Output image](/images/FarField_FFT.png)

Generating this image requires two steps: 1) Running Keller-Miksis simulation for all bubble radii, 2) Taking FFT of all bubble radius vs time datasets genreated

### Running Keller Miksis Simulation

Use this function, with modified parameters to represent the simulation desired, to generate the Keller-Miksis radius vs time datasets

```
KellerMiksis_batch.m
```

For testing purposes, a single Keller-Miksis simulation can be done using:

```
KellerMiksis_single.m
```

### Running FFT and getting Far Field Pressure

After the previous step, run this function, with modified parameters to represent the simulation desired, to generate the output figure

```
FarFieldPressure.m
```

### Natural Frequency of Bubble

For a graph of the natural frequency of bubbles as a function of initial radius, run the following function:

```
NatFreq.m
```

## References
Johansen, K., J.H. Song, and P. Prentice, Validity of the Keller-Miksis equation for "non-stable" cavitation and the acoustic emissions generated. 2017 Ieee International Ultrasonics Symposium (Ius), 2017.

Christopher E. Brennen, CAVITATION AND BUBBLE DYNAMICS, https://authors.library.caltech.edu/25017/4/chap4.htm#L2

## Contributing

Currently contributing is not suppported, please see future versions at https://github.com/drmittelstein/ultrasound_hardware_control to determine whether this changes.

## Versioning
Please see available versions at https://github.com/drmittelstein/ultrasound_hardware_control

## Authors

* **David Reza Mittelstein** - "Modifying ultrasound waveform parameters to control, influence, or disrupt cells" *Caltech Doctorate Thesis in Medical Engineering*

## Acknowledgments

* Acknowledgements to my colleagues in Gharib, Shapiro, and Colonius lab at Caltech who helped answer questions involved in the development of these scripts.
