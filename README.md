# Highspeed Task

## Description

This repository contains all code to run the behavioral task used in Wittkuhn & Schuck (2020), *bioRxiv*, [doi: 10.1101/2020.02.15.950667](http://dx.doi.org/10.1101/2020.02.15.950667)

![task](/task.png)

### Slow trials

In **slow trials** participants have to press a button in response to upside-down visual stimuli (20% of trials) and do nothing if pictures are presented upright (80% of trials).

### Sequence trials

In **sequence trials** participants have to detect the serial position of a target image in a sequence of five images presented at varying speeds (32, 64, 128, 512, and 2048 ms inter-stimulus intervals) and indicate their response after a delay of 16 s after the onset of the object sequence.

### Repetition trials

In **repetition trials**, participants have to perform the same detection task as in sequence task, except that two out of five visual stimuli are repeated a varying number of times and participant are instructed to indicate the serial position of *the first occurrence* of the second (target) stimulus

## Requirements

- MATLAB version R2012b or higher (Natick, Massachusetts, USA; The MathWorks Inc.; see [here](https://www.mathworks.com/products/matlab.html) for details)
- Psychophysics Toolbox extensions; version 3.0.11 (see [here](http://psychtoolbox.org/) for details)

Psychtoolbox is included in this repo as a submodule and the relevant paths are accessed by the task code.

Data reported in Wittkuhn & Schuck (2020), *bioRxiv* were acquired using MATLAB version R2012b (Natick, Massachusetts, USA; The MathWorks Inc.) and the task was run on a Windows XP computer.

The code was successfully tested using MATLAB version R2012b and R2017a.

## Usage

1. In the command line (terminal) clone this repo (e.g., `git clone git@git.mpib-berlin.mpg.de:wittkuhn/highspeed_task.git`) which creates a folder `highspeed_task` in your current working directory (type `pwd` to find out the current working directory) that contains the files of this repo
1. Go into the `highspeed_task` folder using `cd highspeed_task`
1. Activate the Psychtoolbox-3 submodule with `git submodule update --init --recursive` (this clones the contents of the [Psychtoolbox repo](https://github.com/Psychtoolbox-3) into the `Psychtoolbox-3` folder)
1. Open `/scripts/highspeed_run.m` in MATLAB
1. Click `Run` in the MATLAB GUI
1. MATLAB might tell you that "to run this file, you must change the MATLAB current folder". Select the default option to `Change Folder`.
1. In the first dialogue box `Study mode` choose the study mode (e.g., `instructions_condition_1` for slow trials, `instructions_condition_2` for sequence and repetition trials, `practice`, `behavioral`, `mri`)
1. In the second dialogue box, set `id`, `age`, `gender` (must be either `m`, `f`, or `o`), `session` (must be either `1` or `2`), `run` (`1` to `4`)
1. In the third dialogue box, confirm your settings, otherwise `Cancel` and go back
1. Enter the `cbal` counterbalancing factor (`1` to `8`) that determines the sequences used in sequence trials (see Methods section in the paper for details)

Task instructions for participants (in German) as used in Wittkuhn & Schuck (2020), *bioRxiv* can be found in `highspeed_instructions.pdf`.

## Authors

- [Lennart Wittkuhn](mailto:wittkuhn@mpib-berlin.mpg.de), Max Planck Institute for Human Development, Berlin, Germany
- [Nicolas W. Schuck](mailto:schuck@mpib-berlin.mpg.de), Max Planck Institute for Human Development, Berlin, Germany

## Acknowledgements

If you use this task in your work, please cite:

> Wittkuhn, L. and Schuck, N. W. (2020). Faster than thought: Detecting sub-second activation sequences with sequential fMRI pattern analysis. *bioRxiv*, [doi: 10.1101/2020.02.15.950667](http://dx.doi.org/10.1101/2020.02.15.950667).

Please see the license information below for details.

## License

### Code

All code inside the `/scripts` folder was written by Lennart Wittkuhn and is licensed under the [MIT license](/LICENSE).

### Stimuli

The visual stimuli inside the `/stimuli` folder are taken from Haxby et al. (2001), *Science* and are freely available from http://data.pymvpa.org/datasets/haxby2001/.
The original authors of Haxby et al. (2001), *Science* hold the copyright of this dataset and made it available under the terms of the [Creative Commons Attribution-Share Alike 3.0 license](http://creativecommons.org/licenses/by-sa/3.0/).
The original images were *not* transformed or modified for the purpose of the current study.
If you reuse the visual stimuli inside the `/stimuli` folder, please make sure to cite the original authors:


> Haxby, J. V., Gobbini, M. I., Furey, M. L., Ishai, A., Schouten, J. L., and Pietrini, P. (2001). Distributed and overlapping representations of faces and objects in ventral temporal cortex. *Science*, 293(5539):2425–2430. [doi: 10.1126/science.1063736](http://dx.doi.org/10.1126/science.1063736)


### Sounds

There are three different sounds used in this task, placed in the `/sounds` folder.

#### `soundCoin.wav`

The coin sound signals correct responses.
The original sound is the "Coin" sound from the Nintendo Entertainment System (NES) game "Super Mario World" and can be downloaded for free from https://themushroomkingdom.net/media/smw/wav.

#### `soundError.wav`

The error sound signals incorrect and missed responses.
The original sound is the "Yoshi spitting" sound from the Nintendo Entertainment System (NES) game "Super Mario World" and can be downloaded for free from https://themushroomkingdom.net/media/smw/wav.

#### `soundWait.wav`

In the delay period of the sequence and repetition trials (interval between the offset of the last sequence item to 16 s after sequence onset), participants listened to bird sounds to keep them moderately entertained.

The [British Bird Song - Dawn Chorus](https://audiojungle.net/item/british-bird-song-dawn-chorus/98074) were bought with a SFX (Single Use) license from evato market.
Details of the SFX (Single Use) License can be found [here](https://audiojungle.net/licenses/terms/audio_sfx_media_single). In short, it allows to ...

> [...] use the Item to create one single End Product that incorporates the Item as well as other things, so that it is larger in scope and different in nature than the Item.

### Contributing

If you notice any issues or have questions of the task, please [contact Lennart Wittkuhn](mailto:wittkuhn@mpib-berlin.mpg.de) or create an Issue.
Thanks!
