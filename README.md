# MultiNX Camera Control

 __On a local WiFi network, remotely synchronize and control multiple Samsung NX2000, NX300, NX500 cameras, Android phone cameras running the Multi Remote Camera App, and Raspberry Pi Computer Cameras.__
 
 ![Android phone screenshot Start screen](screenshots/Android/Screenshot0003.jpg)

 MultiNX is a cross platform application originally designed to work with Tizen based Samsung NX cameras. MultiNX synchronizes and controls one or more Samsung NX2000, NX300, and NX500 cameras. The application now includes Android phone cameras running the [Multi Remote Camera app](https://sourceforge.net/projects/multi-remote-camera/), m5stack Timer Camera, and Raspberry PI cameras. 
 
 Possible uses for the MultiNX application are photo and video capture sessions where one or more cameras are not easily accessible and wired focus/shutter control is not possible. I have used MultiNX with four NX2000 cameras remotely and twin NX2000, NX300, and NX500 cameras in a stereo camera rig to set camera parameters. Either wireless or USB wired focus/shutter control can trigger the cameras to take photos. 
 
The NX cameras use the open-source Linux based (Tizen) operating system and Samsung provided a way to access it on power-up for diagnostics and testing. This project does not apply to the NX1000 or NX1100 cameras because those cameras use a different (closed) operating system VxWorks, not Linux (Tizen).   MultiNX uses Telnet and HTTP protocol commands to communicate with the connected NX cameras.
 
 The MultiNX application is written in [Processing](https://processing.org/) and Java, and runs on a Windows PC, Linux, or Android device (phone, tablet, and Chromebook). The application may also run in the IOS Processing SDK, but I have not tested. 
 MultiNX runs on Android, Linux and Windows PC platforms where Processing.org SDK can run.

 MultiNX supports up to four multiple camera connections at once. The WiFi connection in each NX2000 and NX300 camera is made with the E-Mail WiFi setup service on the camera, however it does not use the email service. With the NX500, the Menu system turns on WiFi access. It has not been tested with more than four camera connections.
 
 Note: The NX300 and NX500 implementations are not yet complete because not all hardware keys can be controlled remotely. 

 The application connects to each Samsung NX camera over WiFi on a local network. The WiFi network does not have to be connected to the Internet and normally should not be connected to the Internet due to security issues with telnet. For my use, I establish a local network with a USB battery powered mobile router like the TP-Link_290A and other AC powered routers. I have used my Telecom service provider modem router and Android mobile phone hot-spot connection feature. These are connected to the Internet for a short period of time during my tests.
 
 The application only invokes telnet and HTTP protocols to communicate with the cameras. The application does not modify the internal Tizen file system to add shell or application code. The application sends commands to the camera provided by telnet. A start up "autoexec.sh" shell script in the root folder of the SD memory card starts the telnet and HTTP services in the camera. The shell script also starts an optional FTP server for photo transfer after a shoot is finished. The application is not an FTP client. I use [Filezilla](https://filezilla-project.org/) on a PC to transfer photos from all the connected cameras. The FTP server on each camera can be commented out to improve performance. 
 
 With the NX500 camera, Tizen lacks code for Telnet, HTTP and FTP servers execution, so these services were copied from the NX300 and placed on the SD card to start on power up. The NX500 also enters a diagnostic factory mode that disallows touch screen focus unless it is circumvented by installing code in the NX500 file system as described by [ottokiksmaler/nx500_nx1_modding - Running_scripts_without_factory_mode_BT.md](https://github.com/ottokiksmaler/nx500_nx1_modding/blob/master/Running_scripts_without_factory_mode_BT.md) I have not tried this approach yet.
 
 The application synchronizes each camera's exposure settings, does simultaneous focus, and synchronized shutter release at nearly the same time. Shutter release is not simultaneous because individual messages are sent to each camera in sequence. The code does not provide Live-View with the cameras. The application features are limited by what can be done with telnet commands to control the camera and read its status.

 The app needs each camera's IP address to configure the connection. The NX cameras do not show their local network IP address. Only the camera's MAC address is available in the Menu - Settings - Device Information. The MAC address helps to find the camera's IP address with an app like "Network Scanner" in the Google play store. [https://play.google.com/store/apps/details?id=com.myprog.netscan&hl=en_US&gl=US](https://play.google.com/store/apps/details?id=com.myprog.netscan&hl=en_US&gl=US) 
 
 A text configuration file informs the application what cameras to connect with its IP address, camera name, camera type, and camera orientation (0 degrees for landscape and 90 for portrait mode, 180 for upside down).
 
 This MultiNX application code is a work in progress.
 Possible future improvements:
 1. Convert configuration to use a JSON file. done!
 2. Improve User interface, error messaging, documentation
 3. Refactor for simplification, camera design, and more comments 
 4. Add more controls for NX300 and NX500.
 5. For Multi Remote Cameras, add discovery, GUI controls for camera mode and settings.

## Warning Notice

 Using telnet commands incorrectly can lock up the camera, so there is some risk using this application. If the camera hangs, a power-on restores the camera functions after removing and reinserting the battery. The author is not responsible for uses of this software and its possible effect on your camera. __USE AT YOUR OWN RISK__.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 

## How to setup and configure Samsung NX cameras and application

Copy the contents of the sdcard-NXnnnn folder to the base folder of the SD card. Here are instructions for the NX2000 as a setup guide example.

1. For each NX2000 camera copy the autoexec.sh and inetd.conf files from the sdcard-NX2000 folder in this repository to the base folder of the camera memory card. Important - do this after Formatting your memory card. For the NX300 and NX500 camera copy the contents of the folder sdcard-NX300 or sdcard-NX500, respectively to the base folder of the camera memory card.

2. On each NX2000 camera perform the following HOME setup:
	
	> Expert - Manual 
	
3. On each NX2000 camera perform the following MENU setup:
	
	> AutoShare off
	> 
	> Photo Size 2M recommended for quick downloads, otherwise 20M when not saving RAW
	>
	> RAW + Normal (note RAW saves at highest photo size 20M)
	> 
	> Auto focus - Single Auto Focus
	> 
	> Touch Focus  - ON
	>
	> ISO Customizing - ISO Step  1 Step, Auto ISO Range - ISO 3200
	> 
	> Map Direct Link button to E-Mail: Menu - Key Mapping - DIRECT LINK -> Email
	
4. Use Direct Link button to connect to a WiFi router for E-Mail. You will enter a password to access your router. You don't have to be connected to the Internet. Return to camera shoot live view mode. Each time you power on the camera, you will press the Direct link button to automatically sign into your WiFi router. Press OK prompt, and touch back button on the screen to complete the connection. Do not press the cancel button.
	
5. From MENU - Settings - Device Information, get the MAC identification address and label each camera with its MAC address.
	
6. Use an Android app such as "Network Scanner" on your local WiFi network to scan for Samsung cameras and write down the IP address associated with each MAC address you found in step 5.
	
7. Copy the config.json file in the config folder to a folder for the application to find. I use MultNX in the internal root storage area. The json file defines each camera. The camera suffix name appends to photo file name for storage.

	Here is an twin camera side by side configuration for 3D photography. File named: twincameras_tplink_101_102.json
	
```
	
      {	"description": "Multi NX Camera Control Configuration",
	"debug": true,
	"configuration": {
		"camera_rig_description": "twin (3D stereo), lenticular, multiple",
		"camera_rig": "twin",
		"saveFolderPath": "/output",
		"IPaddress": "192.168.0.105",
	},
	"display": {
		"width": 1920,
		"height": 1080,
	},
    "cameras": [
	    { "name" : "NX2000 Left",
		  "suffix": "L",
		  "type_description": "MRC, NX2000, NX300, NX30, NX500, RPI, TMC",
		  "type": "NX2000",
		  "IPaddress": "192.168.0.101",
          "orientation_description": "camera rotation degrees: landscape 0, portrait 90, landscape upside down 180, portrait upside down 270",		
		  "orientation": 0,
		  "horizontalOffset": 0,
		  "verticalOffset": 0,
		  "userId": "",
		  "password": "",
        },
	    { "name" : "NX2000 Right",
		  "suffix": "R",
		  "type_description": "MRC, NX2000, NX300, NX30, NX500, RPI, TMC",
		  "type": "NX2000",
		  "IPaddress": "192.168.0.102",
          "orientation_description": "camera rotation degrees: landscape 0, portrait 90, landscape upside_down 180, portrait upside_down 270",		
		  "orientation": 0,
		  "horizontalOffset_description": "parallax offset to set stereo window for twin camera images (SPM alignment - pixels)",
		  "horizontalOffset": 0,
		  "verticalOffset_description": "vertical offset to align twin camera images (SPM alignment- pixels)",
		  "verticalOffset": 0,
		  "userId": "",
		  "password": "",
        },
	],
	"repeat": {
		"description": "start_delay - capture start delay seconds, interval - seconds between repeats, count - number of repeats",
		"start_delay": 0,
		"interval": 0,
		"count": 0,
	}
    }

```

	Here is a four camera configuration connected using a phone WiFi hotstop. File named: cameraphotonet_LL_LM_RM_RR.json

```
	
       { "description": "Multi NX Camera Control Configuration",
	"debug": true,
	"configuration": {
		"camera_rig_description": "twin (3D stereo), lenticular, multiple",
		"camera_rig": "lenticular",
		"saveFolderPath": "/output",
		"IPaddress": "192.168.0.105",
	},
	"display": {
		"width": 1920,
		"height": 1080,
	},
    "cameras": [
	    { "name" : "NX2000 Left Left",
		  "suffix": "LL",
		  "type_description": "MRC, NX2000, NX300, NX30, NX500, RPI, TMC",
		  "type": "NX2000",
		  "IPaddress": "192.168.216.96",
          "orientation_description": "camera rotation degrees: landscape 0, portrait 90, landscape upside down 180, portrait upside down 270",		
		  "orientation": 0,
		  "horizontalOffset": 0,
		  "verticalOffset": 0,
		  "userId": "",
		  "password": "",
        },
	    { "name" : "NX2000 Left Middle",
		  "suffix": "LM",
		  "type_description": "MRC, NX2000, NX300, NX30, NX500, RPI, TMC",
		  "type": "NX2000",
		  "IPaddress": "192.168.216.18",
          "orientation_description": "camera rotation degrees: landscape 0, portrait 90, landscape upside down 180, portrait upside down 270",		
		  "orientation": 0,
		  "horizontalOffset": 0,
		  "verticalOffset": 0,
		  "userId": "",
		  "password": "",
        },
	    { "name" : "NX2000 Right Middle",
		  "suffix": "RM",
		  "type_description": "MRC, NX2000, NX300, NX30, NX500, RPI, TMC",
		  "type": "NX2000",
		  "IPaddress": "192.168.216.56",
          "orientation_description": "camera rotation degrees: landscape 0, portrait 90, landscape upside_down 180, portrait upside_down 270",		
		  "orientation": 0,
		  "horizontalOffset_description": "parallax offset to set stereo window for twin camera images (SPM alignment - pixels)",
		  "horizontalOffset": 0,
		  "verticalOffset_description": "vertical offset to align twin camera images (SPM alignment- pixels)",
		  "verticalOffset": 0,
		  "userId": "",
		  "password": "",
        },
	    { "name" : "NX2000 Right Right",
		  "suffix": "RR",
		  "type_description": "MRC, NX2000, NX300, NX30, NX500, RPI, TMC",
		  "type": "NX2000",
		  "IPaddress": "192.168.216.54",
          "orientation_description": "camera rotation degrees: landscape 0, portrait 90, landscape upside_down 180, portrait upside_down 270",		
		  "orientation": 0,
		  "horizontalOffset_description": "parallax offset to set stereo window for twin camera images (SPM alignment - pixels)",
		  "horizontalOffset": 0,
		  "verticalOffset_description": "vertical offset to align twin camera images (SPM alignment- pixels)",
		  "verticalOffset": 0,
		  "userId": "",
		  "password": "",
        },
	],
	"repeat": {
		"description": "start_delay - capture start delay seconds, interval - seconds between repeats, count - number of repeats",
		"start_delay": 0,
		"interval": 0,
		"count": 0,
	}
    }

```
	
8. Start the application and select a new configuration. Find the folder with the configuration json file and select it.
	The app will attempt to connect to each camera in the configuration list with telnet.

## Building MultiNX for Windows or Android

Processing SDK version 4.01 builds MultiNX for Windows exe (Java Mode) or Android apk (Android Mode).  

When you build MultiNX for Windows or Android you must add the SelectFile and oscP5 library to the Processing SDK. See [Processing Library](https://processing.org/reference/libraries/) information under Contributions.

[SelectFile Library Documentation](https://andrusiv.com/android-select-file/)

[oscP5](http://www.sojamo.de/libraries/oscp5/)

The SelectFile library only supports internal memory file access on Android devices.

The "Platform.pde" file needs to be modified for either Java or Android by commenting out code sections as specified in the file.

## Using MultiNX app

The latest Android apk can be found in the buildPackage folder in MultiNx.

-------------------------------------

 ![Android phone screenshot](screenshots/Android/Screenshot0002.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0001.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0004.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0005.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0006.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0007.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0008.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0009.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0010.jpg)
 ![Android phone screenshot](screenshots/Android/Screenshot0011.jpg)


The right hand column of soft keys correspond to physical button keys on the NX2000.

1. Focus - Press and hold focus in the connected cameras. Updates the display with camera shutter, FN, and ISO for main camera.
2. Shutter - Press the shutter in the connected cameras and release focus.
3. Left - rotate wheel counter clockwise.
4. Right - rotate wheel clockwise.
5. EV - press the EV button
6. Record - start and stop video recordings.
7. Home - display the Home menu
8. PB -  Playback the photos or video

The bottom row of soft keys provide features for accessing menu keys, and viewing screenshots and photos. It also includes functions for buttons the NX2000 does not have but whose function can be invoked.

1. Screen - displays a screenshot of the main camera (first camera in the configuration list file)
2. Show - display the last photo taken on the connected cameras (up to four images)
3. Save - save the current displayed photos in a folder. The first invocation selects the folder for saving. The MultiNX application only saves JPG photo types in local Windows PC or Android device internal storage folders. To retrieve RAW images directly from the camera, use a FTP client, like FileZilla.
4. Mode - change the camera mode. The application assumes manual expert mode for its operation, but other modes are possible.
5. MENU - display the MENU options.
6. Fn - display the Function options.
7. OK - invoke the soft OK button.
8. EXIT - terminate the application.

The middle bottom Manual Settings soft key toggles changes to shutter speed, F-stop, and ISO. The app syncs all connected cameras with the same settings.

## Keyboard Features

On a Windows 10 PC or Android device with a keyboard such as a Chromebook, input key codes control the cameras and help with debugging.

* 0 - Sync all cameras to same settings. All connected cameras trigger at the same time.
* 1 to 9 - Set numbered camera from the configuration list order as the main camera settings. Only set and trigger this camera.
* Space Key - Capture photos on all connected cameras that sync together, or a single camera selected.

See Input.pde file for other keys used.

## References

Many thanks to Samsung camera enthusiasts for information on how to modify, access, and control the NX cameras. Here are links to sources I found most helpful.

[Github ottokiksmaler/nx500_nx1_modding](https://github.com/ottokiksmaler/nx500_nx1_modding)

[Github hunkreborn/Samsung-NX2000-Moding-Hack](https://github.com/hunkreborn/Samsung-NX2000-Moding-Hack)

[Github ge0rg/samsung-nx-hacks](https://github.com/ge0rg/samsung-nx-hacks)

[Github ge0rg Samsung NX Smart Camera Hacks Wiki](https://github.com/ge0rg/samsung-nx-hacks/wiki/WebBrowser)

[Github HausnerR nx300-hacks](https://github.com/HausnerR/nx300-hacks)

[Github Wiki NX-remote-controller-mod](https://mewlips.github.io/nx-remote-controller-mod/)

[Github Code NX-remote-controller-mod](https://github.com/mewlips/nx-remote-controller-mod)

[Blog: Hacking the Samsung NX300 Smart Camera](https://op-co.de/blog/posts/hacking_the_nx300/)

[Bash shell Busybox HTTP](https://www.geekyhacker.com/2018/06/03/bash-shell-cgi-http-server-using-busybox/)

[BusyBox Usage](https://busybox.net/downloads/BusyBox.html)

[BusyBox HTTP daemon](https://oldwiki.archive.openwrt.org/doc/howto/http.httpd)

[Compare NX1000 with NX2000](https://cameradecision.com/compare/Samsung-NX1000-vs-Samsung-NX2000)

[Compare NX1100 with NX2000](https://cameradecision.com/compare/Samsung-NX1100-vs-Samsung-NX2000)

[Compare NX3000 with NX2000](https://cameradecision.com/compare/Samsung-NX3000-vs-Samsung-NX2000)

[Compare NX300 with NX2000](https://cameradecision.com/compare/Samsung-NX300-vs-Samsung-NX2000)

[Compare NX500 with NX2000](https://cameradecision.com/compare/Samsung-NX500-vs-Samsung-NX2000)

[Auto backup files from the Samsung NX300 camera in the background](https://lemmster.de/auto-backup-from-nx300-via-ftp.html)

[ImageMagick Montage, Tile Examples](https://legacy.imagemagick.org/Usage/montage/#tile)

[Source code for the NX2000 BusyBox v1.20.2 (2013-06-04 15:18:37 KST) multi-call binary. DOWNLOAD](https://busybox.net/downloads/busybox-1.20.2.tar.bz2)

[NX2000 Window Manager Enlightenment](https://www.enlightenment.org/)

[NX2000 OS Tizen](https://www.tizen.org/)

[Samsung Camera Parts](http://samsungparts.com/)

[Samsung Open Source Announcement in photographybay publication](https://photographybay.com/2013/05/25/samsung-nx2000-and-nx300-code-released-as-open-source/)

[Samsung Open Source Announcement imaging-resource ](https://www.imaging-resource.com/news/2013/05/28/redesign-your-own-camera-samsung-nx300-nx2000-source-code-released)

[Samsung Open Source - Digital Cameras -> Hybrid DSC - NX1 NX300M NX2000 ](https://opensource.samsung.com/main)

[DpReview NX300 NX2000 discussion about video quality - NX1000 VXWorks/ NX2000 Tizen](https://www.dpreview.com/forums/thread/3772908?page=2) 
