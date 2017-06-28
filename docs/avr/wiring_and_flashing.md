
# Set Up The ATmega

## What it is
The ATmega is a microcontroller. A microcontroller is a CPU, RAM, ROM and other things (in this case IO pins, ADC and some other fanciness) all bundled into one small chip. You may have worked with one before using the Arduino bootloader. The programming we will be doing is not going to be anything like that.

## The Pin Outs
A list of the pinouts can be found in pinouts.txt which has all of the pin numbers on the left, and the related values on the right. A similar diagram can be found in the ATmega datasheet. If you are ever in confusion, reference one of those sheets so you use the correct pins.

## The Most Basic Configuration
Not all of the pins need to be wired in order to utilize the ATmega. In fact, only 5 pins are necessary in order to use the ATmega (well, technically 3 pins).

```
Ground (5)
```

You learned this in ISIM. Ground yo’ shit

```
Vcc (4)
```

Also learned in ISIM, this is the (main) power for the ATmega. Without this, nothing works. The ATmega can run on as little as 2V and at most 5V. More than that and it will burn, less than that it will not turn on. We usually use 5V.

```
AGND (20)
```

This is Analog Ground. This is required for analog input and is used by the ADC. Don’t fret about this right now, just wire it up with regular Ground (as it should usually be used). 

```
AVCC (19)
```

If you are clever you will note this is Analog Vcc. This powers the analog stuff that that ATmega can do (ex. ADC) Once again, don’t worry about this -- just connect it to the Vcc. 

```
PE0 (31)
```

This is the Reset pin. Setting this pin to 0V will restart the ATmega and the program running on it. In order to ensure that the pin doesn’t “accidentally” go to 0V we will wire this with a pull up resistor of 10KOhms to 5V. If you don’t know what that means, just put a resistor of 10KOhms from this pin to 5V (same as Vcc).

Congratulations! You have now turned the ATmega on! It won’t do anything because you haven’t programmed it. 

## Wiring the ATmega for Programming
I lied. We will need more than 5 pins to use the ATmega, mainly because we have to program it (or else it doesn’t do anything!). Thankfully, some of our ATmegas make it super easy to program, and they have little pins on top that route to the pins needed to program it (And the little pins on top fit perfectly with our AVR programmers!) If you have one of those, skip this step. 

```
VCC (4), GND (5), RESET (31)
```

These are super easy because you have already wired them! Simply put a jumper for them so that they are easy to access.

```
MISO (8)
```

“Master In Slave Out.” This is the feedback mechanism for programming. the “Slave” is the ATmega, while the “Master” is the computer. Mwahaha! This is ATmega -> Computer communication.

```
MOSI (9)
```

“Master Out Slave In.” Weren’t these guys super clever? This is Computer -> ATmega communication.

```
SCK (28)
```

This is the SCI Clock. The ATmega and your computer think at different speeds. Imagine you are speaking to dog; you can’t say things at the same speed as you would to yourself. Instead you have to slow down so that your dog can understand you. It is basically the same thing here. This just syncs the clocks of your computer to the clock of the ATmega, so that valid communication can take place.

## Into the Programmer They Go!
### Plug the AVRdude into your computer (USB -> USB port)
The AVR programmer should light up with a red light. Notice that the other side has six pinouts… I wonder what those mean...

### Plug the pins in the pins with corresponding pins
If you were lucky and have one of the ATmegas with small pins on top, this is super easy. Otherwise, do whatever janky thing works to get these connections in the right place.

|           |          |
| :-------- | :------- |
| (1) MISO  | (2) VCC  |
| (3) SCK   | (4) MOSI |
| (5) RESET | (6) GND  |

If the AVR programmer’s light does not turn green, then you wired it upside down. Flip the AVR programmer to fix the problem. If that doesn’t work, you screwed up or the ATmega is broken.

## You Can Now Program the ATmega!
### Get the Code
You will be able to find code in the blinky/ folder. Clone this repo if you haven't already to get the example code.


### Compile and Flash the ATmega
Go into the cloned folder and run:

```
sudo make TARGET=Blinky flash
```

Check the output log, if there are errors see what they mean and try to debug them yourself. Check your connections. If you are having problems with the code, make sure that the code you want to run is in a folder in the src/ folder; in this case the folder must be named Blinky with the Makefiles that we are running.

### Plug an LED and resistor in series to ground into PE1 (pin 10) (for those of you who don't have pre-made boards)
Watch the LED blink! How fast is it blinking? Can you change the frequency at which it blinks?

### For all of you with pre-made boards
If you're using a board you designed you probably won't be able to actually do the blink and may need to go in and actually edit some code (spooky, I know). This is going to be dependent on how you wired your circuit so I can only give you some general guides. First you will most likely need to change the pin from PE1 to another pin. Reference the datasheet in order to figure out what pin this should be. If you are changing it to another PE pin then all you need to do is change the number in the DDRE and PORTE lines. If, however, you are using a PC pin then what you will need to do is change the line

```
DDRE |= _BV(PE1);
```

to 

```
DDRC |= _BV(PC7);
```

and 

```
PORTE ^= _BV(PE1);
```

to

```
PORTC ^= _BV(PC7);
```

changing the number on PC to the number of the pin you're using (in this example, the number was 7). If that doesn't work try either Google or Byron if he is still around.

