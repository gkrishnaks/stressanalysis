/* Copyright 2014 Gokulakrishna KS <gokulakrishna@rocketmail.com>

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


/*  EXPERIMENTAL STRESS ANALYSIS 

This program was developed for an academic project for Experimental stress analysis using Strain gauges, Arduino Uno and with Data logging. Please refer to the arduino_program in the same repository on how the Arduino program works.

The program "handshakes" with the Arduino this way. Arduino sends A continously until it gets a response from this program. When Arduino gets a response from this program, Arduino sends over data in this format: vref<comma>gaugeoutput1<comma>gaugeoutput2<comma>gaugeoutput3<carriagereturn> and Processing reads it into a string until the carriage return ("\n"). Then it splits the string at comma ',' and stores individual values in float array for further computations. Once the scientific computations are complete, the program writes the results to a timestamped log file in comma separated value format .csv file.

Terminology used in this program:
1) First letter of variable name is in lowercase, second word in variable name has first letter capitalised. Underscore symbol and numbers in identifier is avoided in the entire program.
2) It is known that an array's first element is element[0], but for better readability, In an array, 1st item of consideration is stored in 2nd element of arrays which is element[1]. 
   Therefore strain[1] means first strain, not the second. strain[0] is set to have 0 and is ignored in calculations.

Data log filename : "Log dd\mm\yyyy : hh:00 - (hh+1):00.csv" in the same directory of Processing. 
Example : "Log 14\03\2014 : 16:00 - 17.00.csv" 
The file has individual rows timestamped at the first entry. The first row of the file has column headings.
 
If filename doesn't exist, file is created. Else, it is opened and appended. Since Processing has no "true" append mode for files, it has to be opened, written and closed every iteration. This data .csv log file can then be opened in a program like Live-graph (www.live-graph.org) for plotting real time dynamic graph between various  variables from data file, or it can be opened in Scientific computational softwares or Spreadsheet applications in Office suites like LibreOffice Calc or Gnumeric for post-processing.  

The circuit diagram and also the documentation on engineering topics and explanation on selection of formulae and expressions will be added to the repository at a later date.
*/

import processing.serial.*;     
import java.io.BufferedWriter;
import java.io.FileWriter;
Serial myPort;                  
boolean firstContact = false;
int count=1;
int milliTimer=0;
float secondsTimer=0;
void setup() {
     myPort = new Serial(this, Serial.list()[0], 115200);
     myPort.bufferUntil('\n'); // List all serial ports by println(Serial.list()) if port is not detected.
   // println(Serial.list());// delay(1000); //to make timer in seconds start from 1. That is, millis()/1000 is to be more than 1, So deliberate delay has been added. 
}

void draw() {
  milliTimer=millis();
  secondsTimer=milliTimer/1000.00;
}

void serialEvent(Serial myPort) { 
  int inByte=myPort.read();
  if(firstContact ==false)
  {
    if (inByte == 'A') 
    {
      myPort.clear();
      firstContact=true;
      myPort.write('A');
    }
  }
  else
  {  
  // read the serial buffer:
  String myString = myPort.readStringUntil('\n');
     myString = trim(myString);
     // split the string at the commas
    // and convert the sections into integers:
    //First value sent in is Vref for any future use with it, so take from second value in calculation , i.e [1] array element, which is actually the first strain gauge output.
    // This convention is used to reduce confusion in debugging. [1] means first gauge, or first strain/stress, not zeroth.
    float sensors[] = float(split(myString, ','));
   
    float[] threeStrain={0,0,0,0,0}; //extra space for any future use, three strain means strain as measured in 3 directions by each of the Strain gauge in 0,60,120 configuration
    double[] twoStrain={0,0,0,0,0}; //two strain means reduced strain values in 2 axial directions
    float offset=0; //Change later
      print( "\t" + " Next iteration " + "\n"); 

   for (int sensorNum = 1; sensorNum < sensors.length; sensorNum++) {
      print("Sensor " + sensorNum + ": " + sensors[sensorNum] + "\t"); //for debugging purpose. 
    } println();
    float[] vRatio={0,0,0,0,0}; //first data, plus 3 needed data, plus extra for future use
    double[] stress={0,0,0,0,0}; //2 axial stresses, plus extra space for future use, double for higher precision
    double vonMisesStress; 
    //Calculating 3 directional strains
    float n,d; // n - numerator, d - denominator : For readability of formulae. 
    float leadResistance=1; //change during operation by measurement, in ohms
    float gageResistance=120; //Strain gauge resistance in ohms
   float gageFactor=2; //For strain gauge, from manufacturer's datasheet - 2 with less than 1% variation. 
 //  int[] sign={0,-1,-1,-1,-1};  //zeroth value is 1, as per the convention taken above for arrays. For easy understanding, [1] corresponds to first item, not second item.
    /* For output mV sign positive or negative. Very important to determine compressive or tensile. 
    If compressive, output from bridge is positive due to reduction in resistance of strian gauge, the strain is taken to be negative.
    So the output voltage is multiplied by -1. Else, multiplied by +1. Refer the link on reference section to understand this better */
    
  //Change values of sign to +1 or -1 as per output during experimentation with 0,60,120 strain gauge rosettes.
    for(int y=1;y<sensors.length;y++)
     {
       vRatio[y]=(sensors[y] - offset)/4.72; //Output minus offset whole divided by supply, CHANGE SUPPLY
       n=4*vRatio[y]*(1+leadResistance/gageResistance); 
       d=(gageFactor*(1+2*vRatio[y])); 
       threeStrain[y]=n/d;    
        print("Directional Strain " + y +" = " + threeStrain[y] + "\t");      
     } 
     println();
     //Calculate 2 axial strains
    for(int z=1;z<3;z++)
    {
      twoStrain[z]= (threeStrain[1]+threeStrain[2]+threeStrain[3])/3;
      double constantTerm=2.0/3.0; 
     double sqRoot=java.lang.Math.sqrt(constantTerm); 
          double a=threeStrain[1]-threeStrain[2];
          a=a*a;
          double b=threeStrain[2]-threeStrain[3];
          b=b*b;
          double c=threeStrain[3]-threeStrain[1];
          c=c*c;
          double total=a+b+c;
          //If else - is used here because sqrt() function can't take a negative number as an argument.
          if(total<0) 
          {total=java.lang.Math.sqrt(-total);}
          else 
            { total=java.lang.Math.sqrt(total);}
          sqRoot=sqRoot*total;
      if(z==1)
        {
          twoStrain[z]=twoStrain[z]+sqRoot; //Add to get Principal strain in P direction
        }
      else 
        {
          twoStrain[z]=twoStrain[z]-sqRoot; //Subtract to get Principal strain in Q direction
        }
        print("Principal Strain " + z + " = " + twoStrain[z] + "\t");
    }
    println();
     //Calculate 2 axial stresses 
   //Poisson ratio of Aluminium = 0.33
    // Young's modulus of Aluminium = 70 * 10^9 Pascals  
    double youngsModulus;
    youngsModulus=java.lang.Math.pow(10.0,9.0); 
    youngsModulus=70.00*youngsModulus; 
    double term1; //First term of the product in equation
    float poissonRatio=0.33;
    double muSquared=poissonRatio*poissonRatio;  //Poisson ratio is called mu, so - muSquared
    term1=youngsModulus/(1-muSquared); 
          stress[1]=term1*(twoStrain[1]+(poissonRatio*twoStrain[2]));
          stress[2]=term1*(twoStrain[2]+(poissonRatio*twoStrain[1]));
          print("Principal Stress 1 =" + stress[1] + "\n");
          print("Principal Stress 2 =" + stress[2] + "\n");
          vonMisesStress=(stress[1]*stress[1])-(stress[1]*stress[2])+(stress[2]*stress[2]);
          if(vonMisesStress<1)
          {
            vonMisesStress=vonMisesStress*(-1);
          }
          vonMisesStress=java.lang.Math.sqrt(vonMisesStress); // square root of (double vonMisesStress);
          print("vonMises Stress = " + vonMisesStress + "\t"); 
          println();
   //To measure angle - how much is the straingauge grid 1 (which is the strain gauge at 0 degrees) away from one Principal axis - in degrees. Strainguage at 0 degress, some initial theta is called grid 1
            float strainSum; 
         strainSum=threeStrain[2]+threeStrain[3];
         strainSum=strainSum/2;
         String angle=" "; 
         int check=1; //To know if first two if blocks are executed or not.
         String direction; //Save Clockwise or anticlockwise.  clockwise if (negative result) and anticlockwise if (positive result)
         //String angle;
         if((threeStrain[1]==strainSum) && (threeStrain[2]<threeStrain[1]))
    {
      //println("Above value is theta P in MINUS forty five degrees i.e in clockwise direction");
      angle="Principal axis P is 45 degrees clockwise from grid 1; Principal axis Q is 90 degrees from axis P";
      println(angle);
      check=check-1;
    }
     else if((threeStrain[1]==strainSum) && (threeStrain[2]>threeStrain[1]))
    {
     // println("Above value is theta P with PLUS forty five degrees, i.e in anticlockwise direction");
      angle="Principal axis P is 45 degrees anticlockwise from grid 1;  Principal axis Q is 90 degrees from axis P ";
      check=check-1;
    //  println(angle);
    }
            float angleFromGrid1=0;

     if(check>0)
     {
        n=(sqrt(3.0)) * (threeStrain[2] - threeStrain[3]);
        d=(2.0*threeStrain[1]) - threeStrain[2] - threeStrain[3];
        n=atan(n/d); //Output is in radions... and reusing same float n
        n=degrees(n); //in degress.
        angleFromGrid1=0.5*n;
             //print("Angle of a Principal axis from Grid 1 = " + angleFromGrid1 + "Refer output log file for further info" + "\n"); 

        if(angleFromGrid1>0)
        {
         direction=" Anti-Clockwise";
        }
        else 
        {
          direction=" Clockwise";
          angleFromGrid1=angleFromGrid1*(-1); //to remove negative sign, since "Clockwise" implies negative. 
        }
        if(threeStrain[1]>strainSum) 
        { //"anglefromgrid1 is theta P"); 
          angle="Principal P is " + angleFromGrid1 + " degrees" + direction + " from grid 1 ; Principal Axis Q is 90 degrees from Axis P";
         // println(angle);
          }
        else if(threeStrain[1]<strainSum)
          {
      //"anglefromgrid1 is theta Q");
       angle="Principal axis Q is " + angleFromGrid1 + " degres" + direction +" from grid 1; Principal Axis P is 90 degrees from Axis Q ";   
           //println(angle);
  
   }
   
   else 
    {
      if(((sensors[1]==0) && (sensors[2]==0)) && (sensors[3]==0))
      {
        angle="System under no load. No input from Strain gauges";
      }
      else
      {
      // println("all three strains are same : indeterminate equal biaxial strains");
      angle="Indeterminate angle because individual 3 direction strains are same : i.e Equal biaxial strain ";
             //println(angle);
      }
    }
     
     }  
    print("More info on the angle above : "+ angle + "\t");
    println();
     double shearStrain=0;
     double shearStress=0;
     shearStrain=twoStrain[1]-twoStrain[2];
     shearStress=(youngsModulus*shearStrain)/(2*(1+poissonRatio)); 
     print("Shear Strain = " + shearStrain + "     Shear stress = "+ shearStress + "\n");
     
    double yieldStrength;
     yieldStrength=241*pow(10,6); //in Pascals, for Aluminium 6061 T6 alloy.
    String vonMisesCriterion=" ";
     if (vonMisesStress<yieldStrength)
      {  vonMisesCriterion=" Safe"; }
      else //Will not happen in actual experimental stress analysis with safeloads, unless you do destructive testing to find when material yields
      {  vonMisesCriterion="Failure";} 
     print("vonMises Criterion check : " + vonMisesCriterion + "\n"); 
  // For filename with format : day\month\year:hour (in 24 hour format) , nf function returns a number in string format.
   String timestamp = "Log : " + nf(day(),2) + "\\"  + nf(month(),2) + "\\" + year() + " : " + nf(hour(),2) + ":00"+ " - "+nf(hour()+1,2) + ":00 "; 
  // First column for datalog is to be system time at which the recording was made. 
   String timestamp2= nf(hour(),2)+" : "+ nf(minute(),2) + " : " + nf(second(),2);
     double gpa=java.lang.Math.pow(10,9); //to get output in giga pascals.
  try
  {
      FileWriter output = new FileWriter((timestamp + ".csv"),true); //Boolean true will append the new data, if file exists, else creates a new file and starts appending.
      print("Writing to file..." + "\n");
      if(count==1)  //For first time alone - the table HEADER column
          {
              //Heading row
              output.write("System Time" + "," + "Running time" + "," + "Gauge0 (mV)" + "," + "Gauge60 (mV)" + "," + "Gauge120 (mV)" + "," + "Strain in Principal axis P " +"," + "Strain in Principal axis Q" + "," + "Shear strain" + "," + " Stress in Principal Axis P (Pa) " + "," + " Stress in Principal Axis Q (Pa) " + "," + "Shear stress (Pa) " + "," + " Von mises stress (Pa) " + "," + "Principal Stress in Axis P (GPa) " + "," + "Principal Stress in Axis Q (GPa) " + "," +"Shear stress (GPa)" + "," + " Von Mises Stress (Gpa) " + "," + " Angle of Strain gage grid 1 to Principal axes "+","+ "Von-Mises Criterion Failure mode (if VonMisesStress is less than Yield strength - Safe) " + "\n"); 
              output.flush(); //Flush in
              count=count+1; // update to ignore this block for consequent entries
          }
      //Write data starting from 2nd row (under heading row)     
      output.write(timestamp2 + "," + secondsTimer + "," + sensors[1]+"," + sensors[2]+ "," + sensors[3] + "," + twoStrain[1] + "," + twoStrain[2] + "," +shearStrain+ "," + stress[1] + "," + stress[2] + "," +shearStress + "," + vonMisesStress + ","  + stress[1]/gpa + "," + stress[2]/gpa + "," + shearStress/gpa + ","+ vonMisesStress/gpa + ","); 
      output.write(angle + "," + vonMisesCriterion + "\n");  
      output.flush(); //Flush in
      output.close(); //Close
      //public class Runtime

      delay(50); //to set number of entries per second in data log, imposing delay/ Setting 50ms delay restricts to 11 or 12 entries per second in data log.
      myPort.write('A'); 
   }
 
  catch(IOException e) 
   {
       println("Exception encountered. Perhaps file may not be exist or it's open but in read mode. Or I/O error.  EXIT");
       e.printStackTrace(); //StackTrace
   }
  }
}

