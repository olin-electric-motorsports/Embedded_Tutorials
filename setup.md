
# Setting Up Your Programming Environment

### Install Linux (Any distro)
Although you can program in Windows, I don’t know how nor do I care for learning how to do so in order to teach others. Other than the initial set up, everything else should be identical in Windows. You can go look at older year’s REVO google docs and there is some documentation on how to get things setup on Windows

### Install and Learn Git
For version control on Formula we use git and github. Learn how to use git and learn how it interfaces with github. You will find your code more readily accepted into the main repo if you have good git practice. This is also useful for ModSim and other fun projects.
Check out [https://git-scm.com/book/en/v2/Getting-Started-Git-Basics](https://git-scm.com/book/en/v2/Getting-Started-Git-Basics). 

If you are on Ubuntu, you can easily get git by running
```bash
sudo apt-get install git 
```

### Get on the Olin Formula Github page (aka this)
[https://github.com/olin-electric-motorsports](https://github.com/olin-electric-motorsports)

### Clone and Run the Setup script with all of the tools necessary

Run the `./install_Debian.sh` script to install the necessary tools to program AVRs. You can do this with the following command when you are in this directory.
```bash
$ ./install_Debian.sh
```

Look through and take note of what this script does. It installs some dependencies and then moves around some configuration files. The setup script will allow you to work with the AVR programmers as well as compile the C files into useable Atmega code.

### Get comfortable in terminal
In order to work with the Atmegas you will have to be comfortable working in terminal. You might also want to consider learning Vim, an incredibly powerful text editor that has a steep learning curve. Learning these tools well will not only make you a faster and more productive team member, but will help you in life as well.

###Learn some C
You can work with ATmegas without learning C, but if you want to write any code for them at all, you're going to need it. Use the Kernighan & Ritchie C Programming book; have your computer nearby and prepare to spend a while with it. It's a really good book that you should at least complete the first few chapters of.
