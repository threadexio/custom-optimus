<div align="center">

<h1>Custom Optimus</h1>
<img src="https://img.shields.io/github/license/threadexio/custom-optimus?style=for-the-badge"/>
<img src="https://img.shields.io/badge/NVIDIA-OPTIMUS-green?style=for-the-badge&logo=nvidia"/>

</div>

## What is this?

This is a shell script I made to switch between the iGPU and the dGPU on optimus-enabled laptops. It resembles optimus-manager, but it has some key diffirences.

## Why would I use it?

I made it because I needed maximum battery life on my laptop while having maximum performance while gaming, maybe you are one of those people, if you have the time to install it and get it working properly on your hardware it might be worth your time.

#### Then why didn't you use optimus-manager instead?

Well, at first I though optimus-manager was THE way for Arch laptops, but I didn't want to reboot everytime I wanted to use the other GPU and I didn't want the whole X server to run on only one GPU.

## What are the advantages and disadvantages?

#### Advantages:

-   Better power savings when using the dGPU (`NVreg_DynamicPowerManagement`)

-   You get an unnoticeably small boost in performance when using the dGPU (X still uses the iGPU)

-   You don't have to reboot after switching (only restarting X is required)

#### Disadvantages:

-   Starting an app, while having switched to the dGPU, will default to the iGPU (run with: `run-gpu app_name` to use the dGPU)

-   Modification to some configs may be required before it can work properly

-   It's not as tested, it has more bugs (these will get fixed)

## Finally the installation...

1. Install the required dependencies: `sudo pacman -S bbswitch nvidia nvidia-prime`

	-   Nvidia drivers (`nvidia` package)

	-   Nvidia PRIME (`nvidia-prime` package)

	-   bbswitch (`bbswitch` package)

2. Clone this repository somewhere on your system, doesn't really matter where... just make sure you remember the location (not in /tmp)

```bash
git clone https://github.com/threadexio/custom-optimus custom-optimus && cd custom-optimus
```

3. Run the `install.sh` script and it will guide you

4. After completing all that, do a quick reboot to ensure everything is loaded and ready to go.

5. If you have done all, without errors, it should all work just run `optimus` from your terminal and choose which GPU you want to use

6. To run any app with or without the dGPU use the included wrapper (`/usr/bin/run-gpu`) it will automatically detect if the GPU is active and use it.

	You can test it by running `run-gpu glxinfo | grep "OpenGL vendor"` with the dGPU active and then without it, when running it with the GPU active it should report:

	```bash
	OpenGL vendor string: NVIDIA Corporation
	```

	For example, this is how launch options in steam would look:
	```bash
	run-gpu %command%
	```

**NOTE:** Before switching the GPU, save all of your work because although you don't have to reboot, restarting X also kills the current session along with the open apps

## Some more notes

Tested on:

-   Linux archlunix 5.12.9-arch1-1 #1 SMP PREEMPT Thu, 03 Jun 2021 11:36:13 +0000 x86_64 GNU/Linux
-   Nvidia Driver version: `465.31-7`
-   WM: i3
-   Display Manager: LightDM

To end this super long README, I want to clarify that I have not tested this on other hardware, your experiences and configs may and probably will vary from mine.
