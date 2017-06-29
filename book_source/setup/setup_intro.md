
# Setting Up Your Programming Environment

Before we can start doing some awesome firmware development we have to set up all of the tools necessary for said development.


## Install Linux
Although you can program in Windows, I don’t know how nor do I care for learning how to do so in order to teach others. You may be a die-hard Windows fan, but the truth is that Windows absolutely sucks for development.

I recommend using Ubuntu for people that are new to Linux, as it is easy to use right away. I've found that Ubuntu has its limitations, especially once you start to really customize your Linux experience.

If you truly want to be an elitist, I recommend using Arch Linux.

In general, you can't really go wrong with a Unix-like system.


## Install a Compiler
Unless you want to hand-write some assembly (we'll get to that in the bootloader chapter), you will probably need a *compiler*. 
A compiler takes code written in a programming language and translates it into assembly instructions that will run on a computer.
The compiler might also do some nifty optimizations to make your terrible, inefficient and sloppily written code blazingly fast.
The most popular compiler to exist is the Gnu C Compiler, or GCC.

For us, we will need a *cross-compiler*. 
A cross-compiler is just a compiler that compiles code for a different CPU than the one the compiler is running on.
The microcontrollers we will be programming are not nearly powerful enough to compile their own programs, so we have to do that part for them and just give them the machine code.

The cross-compiler we will be using is a fork of GCC, called AVR-GCC.
This is because it is GCC customized to work with AVR microcontrollers.
Bet you couldn't figure that one out!

Install it with:

`$ sudo apt-get install avr-gcc avr-libc build-essential`

Notice that I sneakily snuck in some seriously scandalous packages into that command.
Just kidding!
They are just some additional packages to ensure that avr-gcc has all the tools it needs to properly build things.


## Install a Programmer (AVR Duuuuuuude)
With our new, fancy cross-compiler we can generate code that will run on our little microcontroller.
The next trick then is figuring out how to get it onto the microcontroller in the first place.
We could just dip the microcontroller in a vat of acid and sprinkle some salt, or we could shine it with some UV rays. 

Instead, we will use an *ISP (In System Programming) Programmer*. 
This is simply a device that will plug into our microcontroller and put our program onto the chip.
There are a few variations out there, but we will most likely be using the AVRISPMKII, which is an obsolete ISP Programmer for use with AVR devices.

In order to interface with the AVRISPMKII (pronounced "A-V-R-I-S-P-M-K-two", or "Avrispmk two") we will need a program called AVRDude (pronounced "A-V-R-dude").

Let's install it now!

`$ sudo apt-get install avrdude`

// TODO: the .avrduderc ???

## Install Build System Utilities
The next two packages are for making the build process much nicer.
We'll go more into detail about why they are necessary, and what the "build process" even is later on.
Just install the things.

`$ sudo apt-get install make cmake`


## Install Git
Last, but not least, we have to install our *version control system*. 
A version control system prevents things like this from happening:
``` bash
program_V1.c
program_v2.c
program_v3.c.backup
program_final.c
program_superfinal.c
prograM_ImSerious_FINAL.c
```

On Formula, we use a *distributed* version control system call Git.
This is currently the most hip version control system out there, given to us by The Linus himself.
We'll go over how to use it effectively later in the tutorial, but for now just get it.

```bash
sudo apt-get install git-core
```

If you are curious about how to use git, I recommend this guide: [https://git-scm.com/book/en/v2/Getting-Started-Git-Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics). 


## As a Recap
Install Things:
`$ sudo apt-get install avrdude gcc-avr avr-libc git-core build-essential cmake`

Set up AVRDude:
/// TODO: ???


