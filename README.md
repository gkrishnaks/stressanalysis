(REAL TIME) EXPERIMENTAL STRESS ANALYSIS 
--------------
<B>WITH STRAIN GAUGES,ARDUINO UNO, AND SCIENTIFIC COMPUTATIONS/DATA LOGGING WITH PROCESSING </b>

This project was developed for an academic project on Experimental Stress analysis on an Aluminium link of a 3PRR manipulator. The circut is made up of Quarterbridge threewire Wheatstone circuit with Strain gauge as one resistor. 0,60,120 Rosette configuration is used for Strain gauges so that three directional strains can be measured for bidirectional stress analysis. 

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

The programs implement "handshaking" for digital communication via USB for serial transmission of 3 strain gauge outputs. Handshaking is necessary because three data has to be sent from the board to computer, in exact required order of 3 straingauge outputs, and exact timing. Example : if the board were to send A-B-C;A-B-C;A-B-C; the computer should pick it up from A, not from B, else it will be taken as B-C-A;B-C-A;B-C-A; And also, the 3 data should be 'read' and sent over only when the computer asks for it - not continuously. 

Arduino microcontroller board sends ASCII 65 ('A') to USB port until it gets acknowledgment response from computer-side Java Processing program. Once acknowledgment is received in the serial, Arduino reads 3 analog inputs, performs ADC, converts them back to voltage, then prints them to serial port as comma separated values. Values such as Initial bridge offset, amplifier gain, external analog reference are to be changed as per the setup and demands before using this code.  
Processing Java program reads serial data received, into a string until the carriage return ("\n") which it expects to be last value to be read. Then it splits the string at comma ',' and stores individual values in float array for further computations. Once the scientific computations are complete, the program writes the results to a timestamped log file in comma separated value format .csv file.  And cycle restarts.

Data log filename : "Log dd\mm\yyyy : hh:00 - (hh+1):00.csv" in the same directory of Processing. 
Example : "Log 14\03\2014 : 16:00 - 17.00.csv" 
The file has individual rows timestamped at the first entry. The first row of the file has column headings.  

If filename doesn't exist, file is created. Else, it is opened and appended. Since Processing has no "true" append mode for files, it has to be opened, written and closed every iteration. This data .csv log file can then be opened in a program like Live-graph (www.live-graph.org) for plotting real time dynamic graph between various  variables from data file, or it can be opened in Scientific computational softwares or Spreadsheet applications in Office suites like LibreOffice Calc or Gnumeric for post-processing.  <b> See sample output data-log file, you may open it with Office Spreadsheet, or any CSV viewer </b>

Further info: 
-------------
Refer full_paper.pdf for Engineering details, circuit diagrams, handshaking logic diagrams and other details.  

Contact the author : gokulakrishna@rocketmail.com, www.twitter.com/gkrishnaks  
The programs are licensed under : Apache License, Version 2.0  
The full paper is licensed under : Creative Commons CC-BY 4.0 International, and it was published in IJERT June 2014 edition and can be found here : www.ijert.org/view.php?id=10457&title=experimental-stress-analysis-on-non-planar-links-of-3-prr-manipulator

<b>References:</b>  
1) Conversion of output voltage to strain for three wire quarter-bridge circuit configuration :
National instruments on Strain gauge configuration types: http://www.ni.com/white-paper/4172/en/  
2) Strain gauges :  
Vishay Micromeasurements databooks on Stress analysis : http://www.vishaypg.com/micro-measurements/databooks/  
3) HBM strain gauge catalog - http://www.hbm.com/en/menu/products/strain-gages-accessories/strain-gauge-catalog/  
4) Processing reference pages and tutorials : www.processing.org  
5) Arduino tutorials from www.opensourcehardwaregroup.com  

