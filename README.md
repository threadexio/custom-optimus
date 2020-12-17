# Custom Optimus

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
<li>The script needs to be ran from a TTY environment
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
<li>Clone this repository somewhere on your system, doesn't really matter... just make sure you remember where</li>
  <pre><code>git clone https://github.com/threadexio/custom-optimus</code></pre>
<li>Run the <code>install.sh</code> script as root. If you care about your don't like running unknown scripts as root, you can perform a manual install:</li>
<pre><code>
sudo chown root:root optimus.service
sudo chmod 644 optimus.service
sudo cp optimus.service /etc/systemd/system (or wherever you like to keep services)
(DON'T ENABLE, START, MASK the service)
sudo pacman -S bbswitch nvidia-prime
echo 'bbswitch' > /etc/modules-load.d/bbswitch.conf
  </code></pre>
<li>Edit parts of the <code>optimus.sh</code> script to fit your hardware and config</li>
<ul>
<li>Line 3: Set <code>displaymng</code> to your display manager (gdm, sddm, lightdm, kdm, etc)</li>
<li>Line 4: The path to the X11 config file that will be created.</li>
<li>Line 69 (nice): This is the configuration for X11 to know how to use the dGPU, most likely you'll have to change this</li>
<li>Line 79: Add more modules options here if needed (usually none are needed)</li>
</ul>
<li>After completing all that, do a quick reboot to ensure everything is loaded and ready to go.</li>
<li>If you have done all, without errors, it should all work just run the script and choose which GPU you want to use
**NOTE:** Before switching the GPU, save all of your work (documents, etc) because although you don't have to reboot, restarting X will also kills the current session
</ol>

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
<li>Linux legion 5.9.14-arch1-1 #1 SMP PREEMPT Sat, 12 Dec 2020 14:37:12 +0000 x86_64 GNU/Linux</li>
<li>Nvidia Driver version: <code>455.45.01</code></li>
<li>DE: KDE Plasma 5.20.4</li>
<li>Display Manager: SDDM w/ default config
</ul>
To end this super long README, I want to clarify that I have not tested this on other hardware, your experiences and configs may and probably will vary from mine.
