
#Understanding Blinky

### All the Code
In the previous tutorial you uploaded a program on your ATmega that made an LED attached to pin 10 blink. You typed a simple line in your terminal and some magic happened, and then your ATmega did stuff.  Well, the code you uploaded to your ATmega looked like this:

```
#define F_CPU (1000000L)
#include <avr/io.h>
#include <util/delay.h>

int main (void) {
    // Set PE1 to output
    DDRE |= _BV(PE1);

    while(1) {
         //Toggle PE1 (pin 10)
         PORTE ^= _BV(PE1);
         _delay_ms(500);
    }
}
```

### Line by Line
We will now (not) go through every single line of code in order to understand what it actually does.

---
```
#define F_CPU (1000000L)
```

This line of code sets up a macro. A brief definition of macro that I found online somewhere: (It’s GNU so it’s Good)

> “A macro is a fragment of code which has been given a name. Whenever the name is used, it is replaced by the contents of the macro. There are two kinds of macros. They differ mostly in what they look like when they are used. Object-like macros resemble data objects when used, function-like macros resemble function calls.

> You may define any valid identifier as a macro, even if it is a C keyword. The preprocessor does not know anything about keywords. This can be useful if you wish to hide a keyword such as const from an older compiler that does not understand it.”
> -https://gcc.gnu.org/onlinedocs/cpp/Macros.html 

So what this line of code does is sets up `FCPU` to be replaced by 1000000L every time `FCPU` is mentioned. The number that you see is 1,000,000 with a Long identifier, which is a big enough data type that it won’t overflow. 

Naively you may think that this line of code sets the frequency of the CPU on the ATmega, and I would tell you that you are clever. Wrong, but clever. Instead, it tells the compiler the frequency of your ATmega. This line needs to be included first because the included libraries will utilize this value.



---
```
#include <avr/io.h>
```

This includes functions for the AVR input and output operations. For our uses, it includes a crap ton of Macros for different memory locations on the ATmega. It is much nicer to write DDRE than 0x001A and causes a lot less confusion. 



---
```
#include <util/delay.h>
```

This allows us to use the `_delay_ms()` function. The `util/delay.h` library calls on the `FCPU` macro, which is why `FCPU` needs to be defined at the very top of the code. Can you piece together why the `FCPU` is necessary for delays?



---
```
int main (void) {
```

For those that don’t know C, this is the “start” of the program when it is run. This is the most important function. We will always define main as per C11 standards and have an int definition along with it.

If you do not know what I mean by this, hit the google’s and get learning (or use the C textbook that is on Slack).



---
```
DDRE |= _BV(PE1);
```

Finally we get into something fun. This line of code is the first thing executed when the ATmega starts. It ORs `DDRE` (a macro)  with  `_BV(PE1)`  (a macro function for a macro… ) Well shit. What does all this mean?

DDRE can be found on the 79th page of the ATmega datasheet that can be found in this folder. DDRE is a macro definition of the memory location of the “Port E Data Direction Register”. A register is a “collection of flag bits for a computer processor” - Wikipedia. If you look at the datasheet you will notice that DDRE is a byte of memory with all of the bits set to 0. So when we OR it, we flip one of those bits to a 1 so that the CPU knows that we want that flag set. 

If you look at the comment in the code, flipping this flag will allow pin 10, or PE1 on the pinouts, to be an output pin. Flipping different flags in different registers do different things and for the most part you will have to look through the documentation to find out what they do.

But this still leaves questions, what does `_BV(PE1)` do? Well you can check the Atmel wiki, but it is quite dense (I recommend it anyway) and isn’t super helpful at this point. In order to really understand what `_BV()` does, we will just go through a diagram of what this line of code does.

We start with our DDRE register, which is the Port E data register. It has all it’s bits as 0, which means that all pins related to this register are not going to be used for output. However, we want to set pin 10, or PE1 (Port E 1), to be used for output. 

|DDRE | | | | | | | | | 
| --------- | --------- | --- |---|---|---|---   |---   |---   |
|Bit  |7|6|5|4|3|2   |1   |0   |
|     |-|-|-|-|-|DDE2|DDE1|DDE0|
|Value|0|0|0|0|0|0   |0   |0   |

The first 5 bits are not used in the DDRE register, which is cool. All of the bits are set to 0 at first as we said before. Now, we want PE1 to have its output flag set so that we can use it for lighting up the LED. We know DDRE is correlated directly with the Port E data register… 

So, if you make the connection, we want to set the value of DDE1 to 1. In order to do this, we will have to use some bit math. 

```
   DDRE :        0000000
			    OR
   VALUE:        0000010
			    =
New DDRE:  	     0000010
```

This will give us DDRE with the correct bit values if we OR it with the VALUE. We can get that value in a number of ways, either by writing the raw hex `(VALUE = 0x02)` or with the actual binary `0b00000010`. We can be clever, and do a bit shift `(VALUE = 1 << 1)`.  All do the same thing, they put a 1 where we need it in the byte. 

Let’s look at the last method a bit more closely:

```
VALUE = 1 << 1
```

Hm… What if we want to set, say pin 11 (PE2)  to be the output pin instead. That would correlate to DDE2. So in order to get the bit in the right place we would do:

```
VALUE = 1 << 2
```

So it seems that if only we could get the second number to correlate more directly to PE1 or PE2 so that the code is easier to read… Well actually PE1 and PE2 are macros that do just that! So now we can do:

```
VALUE = 1 << PE1       
      or
VALUE = 1 << PE2
```

Sweet! Our code is getting more readable. I was trying to think of a clever way of describing what `_BV()` does, but I couldn’t think of any. `_BV()` is just a macro that does the bit shifting, literally. It stands for Bit Value, or the Bit Value of PE1 (or some other pin) in relation to that register.

```
#define _BV( bit )   (1 << bit)
```

is how `_BV()` is defined. All it does is make the code more readable.

In summary: 

```
DDRE |= _BV(PE1);
```

This ORs the bit-shifted value PE1 correlates to with DDRE in order to set that value in the register. 

---
```
while(1) {
```
This sets up an infinite while loop so that the ATmega never completes whatever it is doing in the loop (blinking the LED). 

Personally I prefer for(;;) because it makes it easier to convert an infinite loop into a non-infinite loop very easily if you ever need to down the road, but they are identical. 

---
```
PORTE ^= _BV(PE1);
```
Look at that `_BV()`! Making our code so much more readable. This XORs the bit for PE1. You know what XORing does? It toggles a bit. Like blinking.

---
```
_delay_ms(500);
```
I feel like this line is pretty self-explanatory. The one thing I will add here is that the `FCPU` that we defined way earlier is INCREDIBLY important here. This line says that we want our LED to blink every second (off for half a second, on for half a second). 

Our ATmegas run at 1Mhz. This is necessary information for the compiler to know, so that it can set up how many clock cycles are needed to pass through `_delay_ms(500)`. If we put the wrong value for `FCPU`, then it would check the wrong number of clock cycles and the delay would not delay for the correct amount of time. 

### Phew! 
That was a lot of information, especially for like 9 lines of code. Now to make things more complicated… 
