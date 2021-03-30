# Custom Optimus

![shell-script](https://img.shields.io/badge/Shell_Script-121011?style=for-the-badge&logo=gnu-bash&logoColor=white)
<br>
[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)

## What is this?

This is a shell script I made to switch between the iGPU and the dGPU on optimus-enabled laptops. It resembles optimus-manager, but it has some key diffirences.


## Why would I use it?

I made it because I needed maximum battery life on my laptop while having maximum performance while gaming, maybe you are one of those people, if you have the time to install it and get it working properly on your hardware it might be worth your time.

#### Then why didn't you use optimus-manager instead?

Well, at first I though optimus-manager was THE way for Arch laptops, but I didn't want to reboot everytime I wanted to use the other GPU and I didn't want the whole X server to run on only one GPU.

## What are the advantages and disadvantages?

**NOTE:** Compared to optimus-manager


#### Advantages:
<ul>

<li>Better power savings when using the dGPU (NVreg_DynamicPowerManagement)</li>

<li>You get an unnoticeably small boost in performance when using the dGPU (X still uses the iGPU)

<li>You don't have to reboot after switching (only restarting X is required)</li>

</ul>

#### Disadvantages:
<ul>

<li>Starting an app, while having switched to the dGPU, will default to the iGPU (run with: prime-run app_name to use the dGPU)</li>

<li>Modification to the script may be required before it can work properly</li>

<li>It's not as tested, it has more bugs (these will get fixed)</li>

</ul>

## Finally the installation...
<ol>

<li>Install the required dependencies: <code>sudo pacman -S bbswitch nvidia nvidia-prime</code></li>

<ul>

<li>Nvidia drivers (nvidia package)</li>

<li>Nvidia PRIME (nvidia-prime package)</li>

<li>bbswitch (bbswitch package)</li>

</ul>

<li>Clone this repository somewhere on your system, doesn't really matter where... just make sure you remember the location (not in /tmp)</li>

<pre><code>git clone https://github.com/threadexio/custom-optimus</code></pre>

<li>Run the <code>install.sh</code> script and it will guide you</li>

<li>Edit parts of the <code>optimus.sh</code> script to fit your hardware and config</li>

<ul>

<li>Line 69 (nice): This is the configuration for X11 to know how to use the dGPU, you may have to change this</li>

</ul>

<li>After completing all that, do a quick reboot to ensure everything is loaded and ready to go.</li>

<li>If you have done all, without errors, it should all work just run <code>optimus</code> from your terminal and choose which GPU you want to use</li>

</ol>

**NOTE:** Before switching the GPU, save all of your work because although you don't have to reboot, restarting X also kills the current session along with the open apps

## Known issues:
<ul>

<li>Graphical artifacts in X11:</li>
<pre>If you encounter any of these, including black bars, weird shapes and more, just switch to the any TTY with Ctrl + Alt + F1-12 and restart your display manager</pre>

<li>Desktop Effects not working:</li>
<pre>Desktop effects might get disabled when switching GPUs, if that happens just restart your compositor (it worked for me in Plasma w/ OpenGL 2.0)</pre>

</ul>

## Some more notes
<ul>

<li>Tested on a Lenovo Legion Y-720</li>
<li>Linux archlunix 5.11.8-arch1-1 #1 SMP PREEMPT Sun, 21 Mar 2021 01:55:51 +0000 x86_64 GNU/Linux</li>
<li>Nvidia Driver version: <code>460.67-2</code></li>
<li>WM: dwm 6.2</li>
<li>Display Manager: LightDM</li>

</ul>

To end this super long README, I want to clarify that I have not tested this on other hardware, your experiences and configs may and probably will vary from mine.
