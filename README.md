(REAL TIME) EXPERIMENTAL STRESS ANALYSIS 
--------------
<B>WITH STRAIN GAUGES,ARDUINO UNO, AND SCIENTIFIC COMPUTATIONS/DATA LOGGING WITH PROCESSING </b>

This project was developed for an academic project on Experimental Stress analysis on an Aluminium link of a 3PRR manipulator. The circut is made up of Quarterbridge threewire Wheatstone circuit with Strain gauge as one resistor. 0,60,120 Rosette configuration is used for Strain gauges so that three directional strains can be measured for bidirectional stress analysis. 

<b>I have attached a sample output data-log file, you may open it with Office Spreadsheet, or any CSV viewer, for viewing </b>  

Dependancies :
--------------

1) Arduino Uno R3 - Or any other Arduino board or a clone (You may have to adjust the code!)  
2) Arduino IDE Version 1.0  
3) Processing IDE Version 2.1 (You may have to install the dependancies for Arduino and Processing, check out their  websites)  
4) Strain gauge rosettes - 0,60,120 configuration  
5) Instrumentation amplifiers like INA125 or AD620  
6) Using 0.1% tolerance (or better) resistors are recommended for wheatstone quarter bridges for each of the three strain gauges in one 0,60,120 rosette.  Also make sure the temperature co-efficient of resistance is low so that the resistor won't heat up much on usage and lose the bridge stability.  

About the programs :
-------------

The differential output from each quarterbridge circuit (as the system is loaded, stress on Strain gauge changes, thereby changing its resistance) is fed into a high gain, low noise, precision amplifier like INA125 and the gain is set such that the minimum (No load) and maximum readings (for maximum load) correspond to 0 and 2.5 Volts respectively. 2.5V is the maximum because an external voltage reference of 2.5V is used at the Aref Pin of Arduino Uno for external analog voltage reference for the ADC.

This program performs "handshake" in Serial communication via USB for serial transmission of Data. Handshaking is necessary because three data has to be sent from the board to computer, in exact required order and timing. Example : if the board were to send A-B-C;A-B-C, the computer should pick it up from A, not from B, else it becomes B-C-A;B-C-A. And also, the 3 data should be 'read' and sent over only when the computer asks for it - not continuously. 

Arduino microcontroller board sends ASCII 65 ('A') to USB port until it gets acknowledgment response from computer-side Java Processing program. Once acknowledgment is received in the serial, Arduino reads 3 analog inputs, performs ADC, converts them back to voltage, then prints them to serial port as comma separated values. Values such as Initial bridge offset, amplifier gain, external analog reference are to be changed as per the setup and demands before using this code.  
Processing Java program reads serial data received, into a string until the carriage return ("\n") which it expects to be last value to be read. Then it splits the string at comma ',' and stores individual values in float array for further computations. Once the scientific computations (See references file for explanation of the reduction formula set) are complete, the program writes the results to a timestamped log file in comma separated value format .csv file.  And cycle restarts.

Data log filename : "Log dd\mm\yyyy : hh:00 - (hh+1):00.csv" in the same directory of Processing. 
Example : "Log 14\03\2014 : 16:00 - 17.00.csv" 
The file has individual rows timestamped at the first entry. The first row of the file has column headings.  

If filename doesn't exist, file is created. Else, it is opened and appended. Since Processing has no "true" append mode for files, it has to be opened, written and closed every iteration. This data .csv log file can then be opened in a program like Live-graph (www.live-graph.org) for plotting real time dynamic graph between various  variables from data file, or it can be opened in Scientific computational softwares or Spreadsheet applications in Office suites like LibreOffice Calc or Gnumeric for post-processing.  
<b> I have attached a sample log file in the repo </b>

Further info: 
-------------

Electronic circuit diagrams and also the documentation on the Engineering topics that include reasons for selected forumlae and expressions used, will be uploaded to the same repository at a later date, after its completion. 
Update: I have provided links to the reference pages and manufacturer's databooks that I used for this project in the "References.pdf" file.

Contact the author : gokulakrishna@rocketmail.com, www.twitter.com/gkrishnaks  
The programs are licensed under : Apache License, Version 2.0
