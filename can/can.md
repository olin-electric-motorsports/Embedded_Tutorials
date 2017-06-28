# CAN
This tutorial will cover what CAN is, how our ATmega's utilize CAN and how to use our CAN api to make your Nodes work with our CAN network.

This document will also serve as partial documentation of our CAN API, with more detailed documentation in the `CAN_2015-2016` repo.

### What is CAN?
Most simply CAN is a method of networking an arbitrary system with many different devices. It allows for any device to talk to any other device quickly, easily and most importantly, reliably. It can also do this using only two wires. 

CAN is a way of life.[[+]](null "At this point you should consider turning away and learning CAN on your own. The goofiness will only increase 10x") Well, a way of life in terms of the embedded systems world. You see, CAN is not a program, software or programming language -- it is just a protocol[[+]](null "Invented at Bosch in the 1980s, so it is relatively new in the grand scheme of things."). It says that there are two wires, CAN-Low and CAN-High, that span across many nodes -- called the CAN bus -- and when they have their voltages *pulled together* it counts as a 1, and when the voltages are *pulled apart* it is a 0. What the sequence of 1s and 0s say is also specified in the protocol.[[+]](null "Thankfully, I don't know what we would do otherwise...") All of this can[[+]](null "Hah! Get it? CAN?") be seen in the following diagram pulled shamelessly from Wikipedia:

![CAN-bus.png](https://raw.githubusercontent.com/OlinREVO/CAN_101/master/Tut_6__CAN/CAN-bus.png "Oh look at me, I can do images!")

So there you go, you technically know everything about CAN. It is a bunch of microcontrollers, or other devices, with two wires connecting to all of them that allow for mass data transfer throughout the entire system. It is that simple.[[+]](null "I like things that are simple")

### CAN in Depth
Looking at the diagram above[[+]](null "Seriously, it is the best diagram I have ever seen. I love it. I am going to print it out and marry it. Wait, what is going on?") you might notice some interesting features.[[+]](null "Or you might not, I don't know your life") First things first, what the hell do the different sections mean? You can see the data field, a whopping 8 bits of data, but what the hell is the rest of that crap?

Well, let us venture into the tabular world of tables.[[+]](null "This sentence doesn't make sense, but I had to have a transition.")

| Field | Meaning |
|:--- | :--- |
| Start of Frame | A bit of 0 to tell nodes to start listening, for the CAN line has something to say. Interestingly[[+]](null "Actually this is pretty common, so not that interesting...") the 0 in the CAN bus means a data point, while the 1 is the default. So when no CAN message is going across the line, it is recognized as a bunch of 1s.|
| Arbitration Field | This field is a unique identifier for the message, and what that means is left up to the user to decide.[[+]](null "Awwww, how sweet!") In most cases it says who the message is for (remember there can be a lot of nodes connected to the CAN bus) and what the priority is. How that is done varies, and we will go over that in a future section.|
| Control Field | This field specifies how long the data field will be. It is 4 bits and it says how many bytes[[+]](null "byte = 8 bits") the Data field will be. |
| Data Field | This field holds all the data, whatever that may be. Once again, it is left up to us to decide how to use it.[[+]](null "Kindof, although I will go over why we have no control later on")|
| CRC Field | Error checking field, ensures that the data is transmitted correctly.|
| End of Frame | The ending note for all CAN messages. 7 bits of 1.|

*Note: You can also find all of this on the Wikipedia article about the [CAN bus (LINK)](https://en.wikipedia.org/wiki/CAN_bus "Click me! Click me!") and it gives a more detailed overview!*

### CANopen: An Onion Story
CAN is a cool protocol and all but it doesn't really do much to standardize the practice of communicating messages across the network.[[+]](null "And in many ways that isn't their goal. Any person can make the system do what they want, it is super flexible") This would be great for a system that has all of its parts made in-house because it could just create its own standard. But that isn't the case for most people, and especially not the case for us.[[+]](null "Although I do vote we get a mining & smelting subteam. Or an alchemy subteam -- that would be way better.")

So some people came along and said:[[+]](null "Nobody actually said this. Or maybe someone did. I guess I did.")

> Hey, we'll create a standard that everyone can use for their communication needs! That way everyone can use everyone else's components with very little hassle!

From that came CANopen. At a quick glance at its name it sounds like an Open Source[[+]](null "We <3 Open Source") project to standardize CAN messages. It is not, but it is open in the terms that anyone can use it.[[+]](null "I won't go into politics here.") 

The Sevcon Motor Controller we are using has a CAN intercace that uses CANopen, so it is in our best interest to follow the CANopen guidelines.

### Actually Implementing CAN

So, after many, many hours of research and diving through documentation I have concluded that the actual implementation of CAN is... non trivial. That is a good way to put it. I would not say that it is inherently difficult, there are just *so* many options.[[+]](null "Which is why CAN is so widely used. It is incredibly flexible and can be used for many various applications where different features are required.")

If you do want to get an in-depth understanding of how the CAN system works, check out the `AVR_Freaks_tut.md` in this directory. It is the best overall guide on how to get a functioning CAN implementation up and running. It is also incredibly dense, unforgiving and quite lengthy. 

Instead of going over *how* to get CAN working, I will instead go over how we are using it by referencing our CAN api.

### Using the CAN api

The first step in using the CAN api is to open up the `api.h` file in the `src/inc/` folder. Look it over, and the glorious simplicity it holds. That is hours and hours of reading documentation and testing in order to get basic CAN functionality down to 3 easy-to-use function calls.[[+]](null "Not like I am salty or anything")

Let us skip over the `#define`s for now, and go straight to the core functionality. The three commandments.

```
int CAN_init( void );

int CAN_Tx( uint8_t ident, uint8_t msg[], uint8_t msg_length );

int CAN_Rx( uint8_t ident, uint8_t msg_length, uint8_t mask );
```

The first function is self-explanatory. Call it at the ATmega startup (or whenever you want to start CAN) and it sets up all the flags and bits and whatnots to get CAN started with our system. No other work necessary.[[+]](null "Except if the CAN line is stuck in a dominant mode-- then there will be errors galore")

The next two functions will require some definitions. `Tx` stands for *Transmission*. `Rx` stands for *Receiver*. I could have just called these functions `CAN_send()` and `CAN_receive()` but I didn't because `Tx` and `Rx` are shorter to write.

These two functions require a bunch of inputs, and we will go over them one by one. Both share two common inputs: `uint8_t ident` and `uint8_t msg_length`.

`uint8_t ident` refers to the *message identifier* which is what `CAN_tx()` uses for the Arbitration field and is what `CAN_rx()` looks for in a message to ~~find true love~~ a matching message. 

The types of messages that you can use are defined at the top of `api.h` and all start with `IDT`.[[+]](null "There are also ones with `_l` appended -- ignore those for now") So if you want to send a throttle message along the CAN line you would use something like `IDT_throttle` for `uint8_t ident`.

`uint8_t msg_length` is pretty self-explanatory -- it is the message length for the CAN message. If you notice, both `CAN_tx()` and `CAN_rx()` require a message length, which means the length of the message has to be determined before the message is sent.[[+]](null "There is a good reason for this. If the sender only sends 2 bytes of info, but the receiver expects 4 bytes then the receiver will read 2 bytes of nonsense from the registers. This will lead to many, many issues.")

Thankfully, these lengths are also defined at the top of `api.h` and are the `#define`s starting with `IDT` and ending with `_l`.[[+]](null "The `_l` stands for *length*. It is pretty confusing, I know") 

So if you are sending a throttle message on the CAN line, you would use `IDT_throttle` for `uint8_t ident` and `IDT_throttle_l` for `uint8_t msg_length`. Easy. But wait -- there is another variable! And it has a weird `[]` thingy on it!

### You Should Really Learn C

If you have no idea what `uint8_t msg[]` means, you should learn C. It is honestly really easy.[[+]](null "It gets a bad rep because you have to manage memory manually. It also gets a bad rep because it doesn't suck and other-lanuage users (Java people) feel bad and try to make C sound like trash. It's like West Coast People -- they feel inferior about where they live and always try to make the East Coast sound like trash.") For a quick reminder, it means a pointer.

For a quick side note on coding style: `uint8_t msg[]` and `uint8_t *msg` mean (literally) exactly the same thing. Both are pointers. However, using `uint8_t msg[]` tells someone looking over the code that `msg` points to the beginning of an *array* of values. There is no array type in C, as all arrays decay into points when passed out of/into a function.

"Enough about C Byron!" you might say, "How the hell do I use it?" Well that is easy. The simplest way to explain it is with an example!

### Sending a Message

```
... // Some code comes before which calls CAN_init()

uint8_t msg[ IDT_throttle_l ]; // These sets up msg as an array containing uint8_t elements of size IDT_throttle_l

msg[0] = 0xFF; // FULL THROTTLE!!!
msg[1] ... // The other elements are set.

CAN_Tx( IDT_throttle, msg, IDT_throttle_l ); // Send the message!

... // Some more code will come after
```

It really is that simple. 

### Receiving a Message

Sending a message is simple. Receiving a message is even simpler.[[+]](null "It is not.") The thing with receiving a message is that you have to tell the ATmega to receive the message before it comes, or else it will miss the message.

There are generally hundreds of CAN messages going across the CAN line at any given time -- and generally your node will not give a shit what any of them say.[[+]](null "Except the Watchdog node.") So by default the ATmega ignores all of them.

When you set up `CAN_Rx()` for a specific message ID, such as the throttle message, your ATmega will send an interrupt when a message matching that ID has arrived. You MUST catch this message with `ISR(CAN_INT_vect)`.[[+]](null "If you forgot how to work with interrupts, read an earlier tutorial.")

However, what if you want to catch a lot of messages that go down the line? What if, in fact, you want to read every single message that goes across CAN?[[+]](null "I'm looking at you Watchdog node!") There are only 6[[+]](null "I forgot the exact number. It might be 5. Who cares?") message objects per ATmega which means that you can only set up an inbox for 6 different messages -- it would be impossible if there are 7 unique message IDs!

That is where the `uint8_t mask` variable comes into play. It is a bitmask for the incoming messages. That is just fancy, mumbo-jumbo for a filter.

It works like this: Where `uint8_t mask` has a 1, it compares the message identifier bit with the bit of the `uint8_t ident` value you supplied. Where `mask` is a 0, it does not compare and assumes that it matches.

A `mask` value of `0x00` means that all the bits are 0 (0000 0000). This is a `global` mask, and will cause the ATmega to interrupt for every CAN message that comes down the line. On the opposite end is a `mask` value of `0xff` which is where the bits are all 1 (1111 1111). This is a `single` mask and will only interrupt for an exact match with the message identifier.

Thankfully, you don't have to remember that, because you can just use `IDM_global` for a global mask and `IDM_single` for an exact-match mask. Of course you can also do value in between `0x00` and `0xff`. It gets a bit trickier when you do this as you get to play with bits!

### Okay, Now How Do I Read a Message?

Now that you have received a message, you might want to read it. Sadly, due to U.S. Labor Laws this is illegal. 

Thankfully on REVO we don't care about the law. The first step in reading a CAN message is to figure out which MOb it came from. This can be found in the `CANSIT2` register. Use something like `bit_is_set` to check the different MObs. 

After you figure out which MOb has generated the interrupt, use `CANPAGE` to select the MOb.[[+]](null "Use the datasheet Luke!") Be sure to set `CANPAGE` to `0x00` first. 

Now here comes the easy part. The message is stored in.... *drumroll* .... `CANMSG`! There are some weird features to the `CANMSG` register and I recommend that you read the datasheet section on it.[[+]](null "Section 19.11.6") One thing to remember is that `CANMSG` will auto-increment after every read/write cycle. 

That is basically it. For a simple, 1-byte-length message on MOb 0, the code would look something like this:
```
uint8_t message = 0;
if( bit_is_set(CANSIT2, 0)){
  CANPAGE = 0x00;
  CANPAGE = 0 << MOBNB0; // This doesn't make sense for MOb 0 but for others it does

  message = CANMSG;
}

// message contains the data!
```

It really is that simple.
