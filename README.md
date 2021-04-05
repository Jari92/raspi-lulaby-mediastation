# raspi-lullaby-mediastation
This code uses a bash script to start media files with a half random shutdown sleeptimer (e.g. for bedtime story, lulaby) with auto save. The last played song will be the starting point at the next boot. Tested on headless Rapsberry Pi 3 B+ running Raspbian with speakers over jack output.

Hardware:
  * Raspberry Pi 3 B+
  * Speakers connected via  3.5mm Jack

Software:
  * mplayer

How to use:
  * Setup your crontab to start the script after a short waiting period
    
  @reboot sleep 30 && /home/pi/Desktop/autostart_lullaby.sh
