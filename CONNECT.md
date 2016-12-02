
##

SRV1A: 00204A9E18A1

SRV1B: 00241D83673E (wolverine)

## Minimal Instructions

1. Remove top board.
2. Connect ground to pin 2, TX to pin 3, RX to pin 4  (colors: green, black, red, respectively)
3. Connect through putty or some other terminal program via serial port.
4. Turn on device and hit "xxx" ("x" three times).  You should see the WanPort configuration screen with menu.
5. Use menu option (4 to setup the wireless configuration, 0 to configuer Server for DHCP by setting IP address to 0.0.0.0)

## Instructions

Obtained from [wayback machine](http://web.archive.org/web/20100807101746/http://www.surveyor.com/cgi-bin/yabb2/YaBB.pl?num=1200515001)


configuring Matchport module via serial
01/16/08 at 12:23pm  
*** IMPORTANT NOTE *** - The Matchport WLAN module is a 3.3V device.  If you try to interface to the Matchport with an RS232 interface (+/-12V levels), you will likely damage the Matchport and render it unusable.  Besides the USB interface described below, there are some alternative USB serial devices with 3.3V interfaces listed at the bottom of this post.
 
If you are unable to reconfigure the Matchport using Lantronix DeviceInstaller software -  
    http://www.lantronix.com/device-networking/utilities-tools/device-installer.html
you will need to use a 3.3V serial interface to access the Matchport setup menu.
 
We recently started to modify our leftover Zigbee USB interface boards with Silicon Labs CP2102 bridge chips for configuring the Matchport.  It's a simple modification requiring the USB board, a 4-pin male header (2x2), and 3 wires. 

We connect the GND signal from the USB board to pin position 2 of the header, TX to pin position 3, and RX to pin position 4.
 

 
We then remove the SRV-1 Blackfin camera card from the robot and plug the new header into the 32-pin expansion port, as shown here -
 

 
The drivers for the CP2102 are built into Linux, and can be downloaded for Windows or OS/X from here:
 
======================
Download for Windows
    https://www.silabs.com/Support%20Documents/Software/CP210x_VCP_Win2K_XP_S2K3.zip - Driver
    https://www.silabs.com/Support%20Documents/Software/CP210x_VCP_Win2K_XP_S2K3_Rel ease_Notes.txt - Revision History - Note that for Windows, you only need to run PreInstaller.exe in the WIN_PREINSTALL directory before plugging in the USB radio.
 
Download for Mac OS/X
    https://www.silabs.com/Support%20Documents/Software/Mac_OSX_VCP_Driver.zip - Driver
    https://www.silabs.com/Support%20Documents/Software/Mac_OSX_VCP_Driver_Release_N otes.txt - Revision History
 
For additional drivers, check http://www.silabs.com/tgwWebApp/public/web_content/products/Microcontrollers/USB /en/mcu_vcp.htm - CP210x USB to UART Bridge VCP Drivers download page
======================
 
To configure the Matchport, start a terminal program that interfaces to the USB board, change the baud rate to 9600, turn on the robot power and quickly (within a few seconds) type 3 'x' characters, and you should get the configuration menu for the Matchport.
 

 
When restoring the Matchport to 2500kbps, the settings you need to change are:
 
  Expert (5) -  
     for CPU performance, enter FF
     for clk?, enter 81
     change MTU Size from 1400 to 1024
     skip the rest of the options
  WLAN (4) - set ssid and infrastructure/adhoc  - default is adhoc with SSID set to SRV1
  Channel 1 Serial (1) -  
     for Baudrate, enter -1
     for divisor, enter 2
     for flow control, enter 2
     further down, for FlushMode, enter 80
     for Pack Cntrl, enter C0
     for InterCh Time, enter 3
     skip the rest of the options
  Network (0) - set IP address - default for adhoc setup is 169.254.0.10
  Save and exit (9)
 
If you really get stuck with the Matchport configuration, send an email to support@surveyor.com and we'll send a board, though it will be in kit form (you will have to solder the wires and header yourself).  We may eventually include the board with the robots or possibly sell it as an option, but for now, there is no charge except possibly postage for non-US customers.
 
Additional note - some users are reporting problems getting this to work on Windows with Hyperterminal, perhaps because of flow control settings.  A much better terminal program for Windows is Br@y Terminal, which can be downloaded from http://www.surveyor.com/srvdownload/termv19b.zip , or Tera Term, which is found here - http://hp.vector.co.jp/authors/VA002416/teraterm.html .  The one other option is puTTY - http://www.chiark.greenend.org.uk/~sgtatham/putty/download.html - which seems to work when all of the other terminals have problems.
 
For Mac OS/X users, you can use the 'screen' command as your serial terminal.  Instructions are found here - http://www.surveyor.com/cgi-bin/yabb2/YaBB.pl?num=1208615397
 
For users who do not have access to a USB serial interface as described above, here are some alternatives:
 
    from Germany:  http://www.chip45.com/index.pl?page=littleUSB&lang=en&tax=bcde
    from US:  http://www.pololu.com/catalog/product/391
    more US:  http://www.sparkfun.com/commerce/product_info.php?products_id=198
 
*** IMPORTANT NOTE *** - The Matchport WLAN module is a 3.3V device.  If you try to interface to the Matchport with an RS232 serial interface (+/-12V levels), you will likely damage the Matchport and render it unusable.

## Addendum 1
=============

