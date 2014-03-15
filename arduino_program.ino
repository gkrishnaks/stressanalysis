/* Copyright 2014 Gokulakrishna K S <gokulakrishna@rocketmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. 

*/


/*
EXPERIMENTAL STRESS ANALYSIS WITH STRAIN GAUGES, ARDUINO UNO, AND WITH DATA LOGGING.

This program was developed for an academic project on Experimental Stress analysis on an Aluminium link of a 3PRR manipulator. The circut is made up of Quarterbridge threewire Wheatstone circuit with Strain gauge as one resistor. 0,60,120 Rosette configuration is used for Strain gauges so that bidirectional strain/stress measurements can be performed. 

The differential output from each quarterbridge circuit (as the system is loaded, stress on Strain gauge changes, thereby changing its resistance) is fed into a high gain, low noise, precision amplifier like INA125 and the gain is set such that the minimum (No load) and maximum readings (for maximum load) correspond to 0 and 2.5 Volts respectively. 2.5V is the maximum because an external voltage reference of 2.5V is used at the Aref Pin of Arduino Uno for external analog voltage reference for the ADC.

Values such as Initial bridge offset, amplifier gain, external analog reference are to be changed as per the setup and demands before using this code.

This program performs "handshake" in Serial communication via USB for serial transmission of Data.
setup() calls establishContact() which feeds ASCII 65 ('A') until it gets a response from a computer.
Once response is received in the serial, loop() starts executing. The loop() function reads 3 analog inputs, converts them to voltage, then prints them to serial port as comma separated values - ONLY IF serial data is available (greater than 0), that is : the program on the computer side (Processing, in this project) sends an ASCII 65 ('A') so that lines of code with if block in loop() may execute.

The corresponding Processing program for this project, which is to perform serial communication as explained above, and to perform scientific computations on the data and to store timestamped log results into a Comma separated value file (.csv) can be found along with the program in the same repository.

Electronic circuit diagrams and also the documentation on the Engineering topics that include the reason for selected forumlae and expressions used, will be uploaded to the same repository at a later date.
 
*/
 
int gauge[] = {0,0,0,0};   
int inByte = 0;  
float sgVoltage[] = {0,0,0,0}; 
float vRef=2.5;             //External voltage reference 2.5V to Aref pin
float ampGain[]={0,1,1,1};  //CHANGE amplifier gain as per the setup.
float offset[]={0,0,0,0}; //Initial offset of wheatstone bridges, if any.
void setup()
{
  analogReference(EXTERNAL); //Using 2.5V Analog reference to Aref pin
  Serial.begin(115200); //Begin serial transmission at 115200 bps.
  pinMode(A0, INPUT); //Setting 3 Analog pins in input mode.
  pinMode(A3, INPUT);
  pinMode(A5, INPUT);  
  establishContact();  //Call the function that loops itself till it gets a response from Computer.
}


void loop()
{
  
  if (Serial.available() > 0)  //If there is a response from computer
  {
    inByte = Serial.read(); //Store the data sent from computer
    gauge[1] = analogRead(A0);
    delay(5); //To let ADC Recover
  gauge[2] = analogRead(A3);
    delay(5);
  gauge[3] = analogRead(A5);  
    delay(5);
    //Convert read ADC output (o - 1023) to voltage (0-2.5)
    for(int k=1;k<=4;k++)
        {
          sgVoltage[k]=(gauge[k]*vRef)/1023.00; 
          sgVoltage[k]=sgVoltage[k]/inAmp[k];
          sgVoltage[k]=sgVoltage[k]-offset[k];
        }
    Serial.print(vRef);  
    Serial.print(",");   
    Serial.print(sgVoltage[1]); 
    Serial.print(",");
    Serial.print(sgVoltage[2]);
    Serial.print(",");
    Serial.println(sgVoltage[3]);   //Adds a return ("\n") in the end 
        Serial.flush();  //Wait till serial transmission is complete
  
  }
}

void establishContact() {
  while (Serial.available() <= 0) //Till serial becomes available with a response from Computer
  {
    Serial.println("A");   // send an initial ASCII value.
    delay(100);
  }
}


