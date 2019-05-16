#include "Big_system.h"
//--pump control
//change these values to control how the pressure is controlled in the system.

// positive pressure control high/low values. Units are in KPa. Make sure High > Low


// Negative pressure control high/low values. Units are in KPa. Make sure High < Low, different than positive




//this is how hard the pumps work. 0= 0%, 255= 100% The pumps wont turn on if the value is too low.
int pumppower = 220;

//-----

float inputvalue;
float voltage;
float pressure;


void setup() {
  // put your setup code here, to run once:
  initializepins();
  Serial.begin(19200);

}

void loop() {
  int n_pres_sensor = analogRead(A14);
  int p_pres_sensor = analogRead(A15);
  int o_pres_sensor = analogRead(A13);
  pressurecontrol(n_pres_sensor, p_pres_sensor, o_pres_sensor, pumppower);
  unsigned long currentMillis = millis();
  recvWithStartEndMarkers();
 if (newData == true) {
        strcpy(tempChars, receivedChars);
            // this temporary copy is necessary to protect the original data
            //   because strtok() used in parseData() replaces the commas with \0
        parseData();
        act_on_input();
        newData = false;
 }

  


  if (p_switch) {
    pressure_switch(pin, currentMillis, calltime);
  }

}
