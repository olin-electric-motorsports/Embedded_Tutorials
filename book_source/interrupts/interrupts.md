# Interrupts: Don't Interrupt Me Unless I Say So

You might be thinking that you are an ATmega pro by this point. Inputs, outputs, analog, digital -- you got this.

But what if you want to keep track of 3 digital inputs and 1 analog input. Naively you might think to loop through all of the checks of inputs, and if one triggers do something otherwise go onto to check the next one. This method works[[+]](null "If you implement it properly, of course"), for the most part. Of course the implementation looks ugly, and what if one of the buttons goes off while you are processing a different button press?[[+]](null "Although the ATmega CPU goes at 1Mhz it still takes time to process things.")

Even worse than that, what if one of the buttons is an *emergency* button -- and if you don't catch it the driver could die.[[+]](null "No drivers died while writing this tutorial. Also, do not kill our driver -- that is Rule #1") That might be a bit of an exageration, but you don't want to miss any inputs. And when your Node is dealing with CAN calls, button presses and digital outputs... things get messy.[[+]](null "Especially if one of those operations requires a delay, like lighting an LED up for 1 second")

Well, I am happy to say that there is nothing you can do and it just sucks. Wouldn't that be such a shitty tutorial?

## Interrupts

The best way to handle multiple input checks, and actually the best way to handle even a single input check, is to use interrupts. Interrupts are exactly as they sound, they *interrupt* the code. Imagine the ATmega is talking...

> "Oh hello, I am an ATmega, and I am here to tell you a great story about the trials of my people. A long, long time ag-"
> 
> *Button Press* 
> *Inflates Balloon*
> 
> "-o there was an old man named Charles Gemshwap..."

Notice how the *moment* the button was pressed, the ATmega stopped what it was doing[[+]](null "Telling a great narative") and immediately inflated the balloon. Then it went back to what it was doing, as if no balloon was ever inflated. That is an interrupt -- and they are awesome.

*Note: In order to use interrupts you will have to `#include <avr/interrupt.h>`*

### Tell Me To Interrupt You

Sometimes, though, you don't want the ATmega to interrupt the code it is doing (sometimes there is a very high priority task that needs to be completed) and so the ATmega defaults to not interrupting.

In order to enable `global interrupts` you just have to add a quick little line at the top of your `main()` function.

```
int main(void){
    sei(); // Enable global interrupts

    // Other code...
}
```

The opposite of `sei()` is `cli()` which disables global interrupts. This can be desired for a number of reasons, and they are generally used together for executing an un-interruptable task.

```
int do_something(void){
    cli(); // Disable interrupts

    // Some code that does stuff

    sei(); // Re-enable interrupts
}
```

So now we can enable and disable interrupts at will, but the ATmega won't change anything. The ATmega is really, really stupid. You have to lay it all out for it...

### Set Up My Pin and I'll Interrupt You [[+]](null "This is my new pickup line")

Imagine if you were talking and someone interrupted you for no damn reason?[[+]](null "This happens a lot actually...") You get pretty annoyed. If someone interrupts your story about how you once befriended a giraffe in order to push you out of the way of an incoming car that would have killed you, then y'know, you wouldn't be all *that* annoyed. 

Once again, the ATmega doesn't know what you want to be interrupted by so it defaults to never interrupting you. Thats right, telling the ATmega `sei()` will tell it 

> "Hey, I want you to interrupt me." 

and it will respond with:

> "Okay."

Then you press a button, and it won't do anything. So you might say:

> "Hey, why didn't you interrupt me? You just sat there doing nothing!"

And it would respond, like a good friend, with:

> "Well, you didn't tell me *when* you wanted to be interrupted."

You might think this is bad behavior, but it is highly preferable. Otherwise a floating voltage at a pin may accidentally toggle an input pin[[+]](null "This is why we use pull-down/up resistors!") and the ATmega would interrupt you randomly for a pin you don't care about. 

Now you are probably thinking:

> "Okay Byron, I get it. Now just tell me how the hell to do this and stop making all of these stupid text boxes."

to which I would respond:

> "I realized I wasn't using enough of these text boxes, so I figured I would use them!"

### External Pin Up Girls and ATmegas [[+]](null "I had two paths in life -- I chose the nerdy path. I regret everything")

*Note: There are a number of different interrupt options; this applies to external interrupts such as button presses. we'll go over other ones briefly later.*

It would be easy enough to just tell the ATmega to interrupt you on pin 16.[[+]](null "This will be our example pin for interrupts!") But *when* would it do that? When the voltage is 0? Should it repeatedly tell you the voltage is at 0? Or should it be when it is at 5V? Should it just tell you when the voltage has changed, or when it reaches a certain point?

Well it is time to open up that handy-dandy ATmega tutorial.[[+]](null "You still have it around right?") Go to page 56, or section 12.2.

What you will find there is the documentation for how to set up these interrupt pins. Most basically, you set the bits for `EICRA` to set up *what* the interrupt will look like and you set up the bits for `EIMSK` to tell it which pins to look at.[[+]](null "Note that the setup for EICRA applies to *all* the pins in EIMSK; so you can't get behavior on two different interrupt pints.")

For example, to set up pin 16 to generate an interrupt when the voltage goes low (0V) you would do:

```
EICRA = _BV(ISC00); // Trigger on 0V
EIMSK = _BV(INT0);  // Pin 16 is interrupt
```

There are a few other things to note in the documentation, and I ~~recommend~~ require you to read all of section 12.[[+]](null "It is short -- don't be a baby") 

However, you aren't done yet. What will the ATmega do with this interrupt it has generated? If you don't tell it to do anything, it is going to crash and that is not good.[[+]](null "I am actually serious, if you don't set it to do things with an interrupt it will call an error call and restart the program. Can cause some weird bugs.")

#### The ISR()

Now the C standard does not say how to implement interrupts.[[+]](null "And rightly so, that is too much bureaucracy for my taste. Bad enough they tell us `int` stands for integer.") For different compilers you may see different implementations, but thankfully at REVO Electric Racing[[+]](null "We just changed our name -- its weird. Gotta update that Resume!") we use AVR-GCC which has a nice implementation:

```
ISR( {VECTOR} ){
    // Do something
}
```

Let's break this down.[[+]](null "Fine... I'll break it down. Y'know you don't really do anything. I think it is unfair that the writer of the tutorial has to do everything, I think tutorials should be a give and take between the reader and the writer.")

- `ISR` stands for the *Interrupt Service Routines* and will let the ATmega know what to keep track of for interrupts. 

It is hard to really break down what the call *is*. You don't use it in a function call or in the `main()` function, it is almost like a definition of a function, but with wierd syntax. Check out the example code to see what it looks like in real life.

- `{VECTOR}` is an identifier for the interrupt to be used. We'll go over this real soon!

- Between the brackets where the `//Do something` comment is is where we will write what we want the ATmega to do on an interrupt. 

Imagine it as a function call that is only called when the interrupt happens -- which means you can do anything! [[+]](null "If you put your mind to it!") It is a bit wierd functionality, and it may take you a bit of time to get used to it.[[+]](null "There are also some cases where you would want nothing to happen on an interrupt -- look through the documentation to get some ideas! Be creative!")

---

This seems simple enough! Now we just need to go over what the VECTOR is...

#### Vector

The interrupt vector is a unique identifier to tell the ATmega what to keep track of for interrupts. You see, the most basic of interrupts are the input interrupts. But there are also software interrupts (such as timers and CAN calls[[+]](null "Shhhhh!!! Just a sneak peak of what is to come!"). There isn't really a list of what interrupt vectors are available[[+]](null "I will be looking into compiling one of some sort"), so you might need to do some googling in order to find what you need. 

However, basic input interrupts vectors are easy to find. Look through the pinouts list, and everything with an `INT` in the name is not an integer, but an *interupt.* You then just append `_vect` to the end of the name in order to get the unique identifier.[[+]](null "Isn't that fancy?")

For example, Pin 16 is `INT1` (interrupt 1) and you would do:

```
ISR( INT1_vect ){
    //Do something
}
```

`INT{0-3}` are general input interrupt pins, while `PCINT` pins (which is every pin except 5 of them) are Pin Change Interrupt. A lot of this information is also an easy google search away!

## A Summary

Alright, so I threw a lot at you.[[+]](null "You deserve it.")  Let's list out all the things you need to do to set up an interrupt:

- Enable global interrupts ( with an `sei();` call)
- Set up pins with what counts as an interrupt and which pins to detect on
- Give a thing to do with an interrupt using the correct vector identifier

A lot of this may still be confusing -- and that is okay! Look through the example code[[+]](null "Check out the comments -- this is how your code WILL look."), play around with it; try using this in your programs. If you run into problems Google is your friend[[+]](null "I am not") and look through the documentation.
