# MultiNX Camera Control

 Remotely synchronize and control multiple Samsung NX2000 cameras on a local WiFi network

 MultiNX is a cross platform application for synchronizing and controlling Samsung NX2000 cameras. It uses Telnet and HTTP protocols to communicate with the connected NX cameras. MultiNX is available for Android and Windows platforms.  MultiNX supports up to four multiple NX2000 camera connections at once. The WiFi connection in each NX camera is made with the E-Mail WiFi setup service on the camera, however it does not use the email service. It has not been tested with more than four camera connections, but should work with many more multiple cameras depending on the resources of the computer running the application.

 The MultiNX application is written in Processing and Java, and runs on a PC or Android device (phone, tablet, Chromebook). The NX2000 camera runs an open-source Linux based (Tizen) operating system and Samsung provided a way to access it on power-up. 
 
 The application connects to each Samsung NX2000 camera over WiFi on a local network. The WiFi network does not have to be connected to the Internet and normally should not be connected to the Internet. I establish a local network with a battery powered mobile router like the TP-Link_290A. I also use my Telecom service provider modem and Android mobile phone hot-spot connection feature. 
 
 The application only uses telnet and HTTP protocols to communicate with the cameras. The application does not add shell code to run inside the camera and does not modify the camera firmware. It only uses commands provided by telnet. A start up "autoexec.sh" shell script in the root folder of the SD memory card starts the telnet and HTTP services in the camera. The shell script also starts an optional FTP server for photo transfer after a shoot is finished. The application is not an FTP client. Use Filezilla on a PC to transfer photos from all the connected cameras. The FTP server on each camera can be commented out to improve performance.
 
 Using telnet commands incorrectly can lock up the camera, so there is some risk using this application. A power-on restores the camera functions after removing and reinserting the battery. The author is not responsible for uses of this software and effect on your camera. USE AT YOUR OWN RISK.
 
 THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 
 This MultiNX app code is a work in progress and in-complete rapid prototype. There are many improvements possible.
 
 The application synchronizes each camera's exposure settings, does simultaneous focus, and synchronized shutter release at nearly the same time. It does not provide Live-View with the cameras. The application features are limited by what telnet commands the camera firmware allows to control the camera and read its status.

The NX2000 camera does not show its local network IP address. Only the camera's MAC address is available in the Menu - Settings - Device Information. The MAC address helps to find the camera's IP address with a "Network Scanner" Google play store app. The IP address is needed to configure the software for the cameras to be connected. A text file informs the application what cameras to connect, camera name, and other (unimplemented) options.

##How to setup and configure the app

	1. On each camera do the following recommended setup:
	
	 Manual mode
	 
	Auto focus - Single Auto Focus
	Touch focus
	Map Direct Link button to E-Mail: Menu - Key Mapping - DIRECT LINK -> Email
	
	2. Use Direct Link button to connect to a WiFi router for E-Mail. You will enter a password to access your router. You don't have to be connected to the Internet. Return to camera shoot live view mode. Each time you power on the camera, you will press the Direct link button to automatically sign into your WiFi router. Press OK prompt, and touch back button on the screen to complete the connection. Do not press the cancel button.
	
	3. From MENU - Settings - Device Information, get the MAC identification address and label each camera with its MAC address.
	
	4. Use an Android app such as "Network Scanner" on your local WiFi network to show Samsung cameras and write down the IP address associated with each MAC address you found in step 3.
	
	5. Now create a text file in a folder for the application to find. The text file contains a line for each camera as follows: IP Address, space, camera name, space, camera type NX2000, space, and camera orientation in degrees 0 (unimplemented feature)
	Here is an example file named: twincameras_tplink_101_102.txt
	
	192.168.0.101 L NX2000 0
    192.168.0.102 R NX2000 0

The camera name appends to photo file name as a suffix _name.

6. Start the app and select a new configuration. Find the folder with the configuration text file and select it.
The app will attempt to connect to each camera in the configuration list with telnet.

## Using MultiNX app

1. 
