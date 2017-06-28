#Blinky With Button Control
(Advanced Blinky)

## The Code
By now you probably think you are hot shit and that you can do anything. You can output 5V on a pin, and you know what? For some things that is enough.  Sadly, for literally everything else, you are going to need some inputs. 

#### Digital Input
The first, and easiest, input that you can do is just digital. 5V will be a 1, and 0V  will be a 0. Easy peezy.

## We Live in a Digital World
Like seriously everything we own is digital.

#### Set a Pin to Digital Input
This is actually really easy. Let’s use pin 10, or PE1. For digital output, we had to set the correct bit of DDRE to a 1. For input, we set it to 0, or, because they default to 0, we leave it as is. 

However, that is shitty code practice, and if you assume that the bit is set to 0 in your code I will find you and I will tell you that you did something stupid[[+]](https://github.com/OlinREVO/CAN_101/tree/master/Tut_4 "You should feel bad"). Instead of assuming like an asshole programmer, you can set it nicely like so:

```
DDRE &= ~( _BV(PE1) );
```

This ANDs the bits of DDRE with the inverse of the bits set by PE1. “What?” you may ask. Essentially, `_BV(PE1)` will create 00000010 and the inverse of that (~) is going to be 11111101. ANDing that with whatever DDRE is will keep every bit of DDRE the same, except for the 2nd to last bit (the one we want for PE1) which it will force to 0. If you don’t understand that explanation go play around with binary [(LINK)](https://www.codecademy.com/courses/python-intermediate-en-KE1UJ/0/1 "Click the link to learn some binary (in python)!"). 

#### Read that Pin
Now comes the hard part. Actually, this is still really easy. To read the voltage at the input pin, we have to look at a new register. The Port E Input Pins Address (or PINE). If 5V is applied to pin 10 (PE1), then PINE will have a bit flipped to a 1 where PE1 is. 0V the bit will be a 0. So you just check to see if PINE is greater than 0.

Not really! Instead we have to see if the bit position of PE1 in PINE is set to 1 or 0. If you aren't comfortable with bit-stuff this can seem like a daunting task. To do this with bit-twiddling you would write the following code:

```C
if (PINE & _BV(PE1) ) { // This ANDs PINE and the bit position of PE1, which gives us a 0 or a number greater than 0 if the bit position of PE1 is set.
	// Do stuff
}
```

Thankfully, the AVR Gods decided it would be a good idea to include a macro which makes this *even simpler* to do:

```C
if (bit_is_set(PINE, PE1))
{
    // Do stuff
}
```

The second method is a lot easier to read, and much less prone to mistakes, so be sure to use it instead! The first method was only included for reference to what the macro expands to, because you should never use something you don't understand!

## Putting It All Together

You can find an example in the `example/` folder for this tutorial. Check it out; modify it; break it; live life!

