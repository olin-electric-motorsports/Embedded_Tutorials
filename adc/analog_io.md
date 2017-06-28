#Blinky With Potentiometer Control
(Super Advanced Blinky)

## Analog Input
Digital input, and digital things in general, are rather easy to understand. It is either off or on, 0 or 1. We don't worry about the things in between, because in a digital world they don't exist.

Sadly, in the embedded world, not everything is clear-cut digital. In the real world there are analog signals. Analog signals are continuous, and there is an infinite number of them. Between 0V and 5V there are an infinite number of different voltage levels, from 0.5V to 3.4582V. Its wild.

Thankfully, we have tools that allow us to convert an analog signal into a digital signal, and vis versa. 

## Analog Discovery? 

#### Analog to Digital
Digital is easily defined by 0V or 5V, a 1 or a 0, on… and off. Easy stuff. Literally two things you have to remember. BI-nary. Analog is everything else. 0V to 5V inclusive in our case, because anything more and our ATmegas will fry. You don't want that unless you are the Powertrain subteam '14.

If we want to work with an analog signal, we have to find a way of representing that analog signal in a digital world. One way is to represent discrete voltage levels as numbers in binary. For example if we represented them as unsigned 8-bit numbers, 5V would be 0xFF (255 in base 10), and 2.5V would be 0x7f (127 in base 10).

Thankfully there is a device that does that for us. Its unintuitively called an Analog-to-Digital converter (hereafter lovingly referred to as an ADC). Usually when talking about an ADC we specify how many bits the ADC represents the analog signal in. Out ATmegas have a built in 10-bit ADC in them, which means that it will represent analog signals using a 10-bit number (giving us 2^10 subdivisions of 0V-5V).

If an analog signal is in a steady-state (which means not changing over time), then this is all we need to know when working with ADCs. However, very rarely are things that easy. Usually analog signals are varying over time, such as a sine-wave or some other constantly-fluctuating signal. This means we need to talk about another aspect of reading analog input.

#### Time. It is always Time. 
This issue isn’t actually analog specific. Digital stuff relies on time too. Actually, everything relies on time. 

As we learned before, our ATmega’s CPU runs at 1MHz by default (some people will have a 16MHz crystal on them which allows us to bump that CPU to 4MHz), which is pretty darn fast. In order to use the ADC, we have to tell it at what time rate to sample the voltage on the pin in order to get a reading. I recommend reading the [wikipedia article](https://en.wikipedia.org/wiki/Analog-to-digital_converter "Link to ADC wiki") to understand this because you will get a deeper understanding of what is going on.

To do this, we use this line of code:

```C
ADCSRA |= _BV(ADEN) | _BV(ADPS2) | _BV(ADPS1) | _BV(ADPS0);
```

Note: You can use `|` in between to combine the bits to be flipped. This is the fanciest combo-bit-shifting mumbo-jumbo that is allowed on one line. Anything more and I will hunt you down and make you turn it into multiple well-commented lines.

We know by now what most of this code does, it sets different bits of the ADCSRA register. ADEN will turn the ADC on, and ADPS[0-2] will tell the ADC how fast to run. Check the datasheet for exact specifications. Remember, Ctrl-F is for quitters!

#### Who Do I Reference? Are You My Relative!?
No, I am not talking about when you write a research paper. This is for the ADC. Voltage is relative, as is everything in life #deep. The ADC will translate voltage into numbers, but it needs to know what the base voltage should be.

For now, we will just keep that idea in the back of our head, and set the ADC to just reference internal ground and input voltage (Analog Vcc).  We could do fancier if we needed it, but we don't.

```C
ADMUX |= _BV(REFS0);
ADCSRB |= _BV(AREFEN);
```

#### Multiplex Me
Before I go into how to read the ADC, we have to go over where the ADC sources its input voltage. 

There is only one ADC on the ATmega but we can use 11 different pins to convert analog to digital. The ATmega does this by *multiplexing* the ADC input. This means that it will only do one conversion at a time, and when it is done it will go onto the next one. All 11 pins can use the ADC for different purposes.

By default the ADC input pin is ADC0 (pin 11). You can change this in the ADMUX register by selecting a different *channel*. You can find the data for this on page 232 of the datasheet, or section 21.10.2. There are many different channels you can switch the ADC to, including internal temperature monitoring! How nifty is that!

To switch the channel, we use the ADMUX register. For now, we won't do anything with it, but it is really easy to work with.

#### Are We Done Yet?
Actually, yes. Mostly.

Now we just have to read the ADC. This is actually fairly easy. First we tell the ADC to begin conversion:

```C
ADCSRA |= _BV(ADSC);  
```

If you look through the datasheet under the ADCSRA register section, it says that you set the ADSC bit when you want a conversion, and then the bit will be automatically reset (set to 0) when the conversion is complete. Since the ADC is not instantaneous, let’s wait for it.

```C
while(bit_is_set(ADCSRA, ADSC));
```

As you can probably tell, `bit_is_set()` will check to see if the bit… is… set? Yes. We could also just do some binary logic with &s and whatnot, but this function makes the code more readable.  Then we just read the ADC when this while loop exits:

```
uint16_t reading = ADC;
```

We have to use a 16-bit integer to hold the ADC value, because an 8-bit integer type can't hold it (remember the ADC we have will output 10-bits). We can't use a 10-bit integer because those don't exist! Try to think about why there would be a 10-bit ADC if there are 6 wasted bits in order to store its value.

And that is it, we now have a reading of the voltage!

## Digital To Analog. Wait, what?
Analog to digital now makes sense, but there is no possible way you can go from digital to analog. That just doesn't make any sense. Well you are right. In a sense. 

Once again, it boils down to:

#### Time. Or Thyme.

1s and 0s. That is what you have to work with. C'mon, you're in ISIM! You are a genius at this. Oh now wait, all you know is filters. And op-amps.

Wait a second, filters are cool, they can take a really spiky signal and smooth it out. You can get rid of high frequency noise and just get the signal you want! What if we use that high frequency noise to MAKE the signal?

This is the idea behind Pulse Width Modulation (PWM). You pulse a bunch of 1s (5V) and 0s (0V) at the digital port such that the "average" is the voltage you want. It is slightly more complicated in practice, and you should definitely check the [wiki article](https://en.wikipedia.org/wiki/Pulse-width_modulation "I supply the link. You read.")

#### Yeah the ATmega Can Do it.
These things are pretty neat. Can your computer do PWM? Well, probably. Whatever. 

Naively you might think you need to write code that constantly changes the output of one of the digital output pins, which honestly would be a pain. Especially because figuring out the timing would be awful. Thankfully, the AVR Gods gave us a system that does all this work for us. And it works asynchronously!

Our ATmegas have two built-in timer circuits, which can be set to do a number of time-related tasks. There is an 8-bit timer and a 16-bit timer, and the concept is that they count up to a number and then do something when they get to that number and then reset themselves. Obviously the 16-bit timer can count to a higher number than the 8-bit number. Orders of magnitude higher, in fact. 

For now, we will just use the 8-bit timer. First we have to set the prescaling on the PWM clock. This is fancy mumbo-jumbo for how fast we want the PWM frequency to be.  For right now, we want it to be as fast as possible: (Remember to reference the datasheet to understand this stuff!)

```C
TCCR0B |= _BV(CS00);
```

Now we just have to say what pin we want to use as the PWM. Not every pin can do PWMing, so you will have to check the datasheet for specifications. Our lovely pin 10 *can* do PWM, so let's just use that one! However, since we are using it's PWM functionality we have to call it by it's other name: `COM0B1`. Y'know, its like how at a party you go by a different name. Like Charles Genschwap. Or something.

```C
TCCR0A |= _BV(COM0B1) | _BV(WGM00);
```

We also set the WGM00 bit, which determines the “mode” of operation. Check the datasheet for more information, but this will set it to be phase-correct PWM.

It is also good practice to ensure the other pin-output is set off.

```C
TCCR0A &= ~_BV(COM0B0);
```

You know what this does by now! Lastly, we still need to tell PE1/pin 10/COMOB1 to be output. For this, we will once again use the familiar `PE1`[[+]](NULL "For readability? No. For standards.").

```C
DDRE |= _BV(PE1);
```

#### Now Just Write To The Pin
You can do this! Well, it is a bit different now.

```C
OCR0B = (uint8_t) 0x34; // You could also use any other random number
```

The OCR0B register is only 8 bits, so any 8-bit number works. The type-casting is unnecessary here, but helps reaffirm this fact.

See? Easy. One might even call it intuitive if they were the one to design it. Nobody else would call it that.

## Putting It All Together
You have a lot more functionality now, and in fact basically all the functionality the ATmega can do. Digital input, output and analog input and output. What more is there? Well, there are a few more built in features that utilize these two features to build up other features that we can use, but we will get to that later. For now, be glad you can do stuff. 

You can find an example in the example/ folder. This will both read a value from the ADC and then use that value to PWM an LED and change the brightness! Neato!

