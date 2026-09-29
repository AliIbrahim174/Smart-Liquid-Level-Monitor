/*
 Smart Liquid Level Monitor
 ESP8266 NodeMCU V3
 Real sensor + simulation rooms
*/

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <LiquidCrystal.h>
#include <EEPROM.h>

LiquidCrystal lcd(D1,D2,D5,D6,D7,D0);

#define SENSOR_PIN A0
#define EEPROM_SIZE 256

#define ADC_0 14
#define ADC_25 540
#define ADC_50 586
#define ADC_75 605
#define ADC_100 630

const char* ssid="LiquidMonitor";
const char* password="liquid123";

ESP8266WebServer server(80);

struct BottleConfig{
  char liquid[32];
  int capacity;
  float warning;
  float critical;
};

BottleConfig config={"Not Set",0,25,10};

struct SimRoom{
  int level;
  String status;
};

SimRoom rooms[4]={{0,""},{72,"NORMAL"},{80,"NORMAL"},{5,"CRITICAL"}};

int adcValue=0;
float level=0;

void saveConfig(){
 EEPROM.put(0,config);
 EEPROM.commit();
}

void loadConfig(){
 EEPROM.get(0,config);
 if(config.liquid[0]=='\0'||config.liquid[0]==0xFF){
  strcpy(config.liquid,"Not Set");
  config.capacity=0;
  config.warning=25;
  config.critical=10;
  saveConfig();
 }
}

int readSensor(){
 long s=0;
 for(int i=0;i<20;i++){
  s+=analogRead(SENSOR_PIN);
  delay(2);
 }
 return s/20;
}

float calculateLevel(int adc){
 if(adc<=ADC_0)return 0;
 if(adc<=ADC_25)return (float)(adc-ADC_0)/(ADC_25-ADC_0)*25;
 if(adc<=ADC_50)return 25+(float)(adc-ADC_25)/(ADC_50-ADC_25)*25;
 if(adc<=ADC_75)return 50+(float)(adc-ADC_50)/(ADC_75-ADC_50)*25;
 if(adc<=ADC_100)return 75+(float)(adc-ADC_75)/(ADC_100-ADC_75)*25;
 return 100;
}

String statusText(){
 if(level<=config.critical)return "CRITICAL";
 if(level<=config.warning)return "LOW";
 return "NORMAL";
}

void statusAPI(){
 String j="{";
 j+="\"room\":1,";
 j+="\"mode\":\"REAL\",";
 j+="\"level\":"+String(level,0)+",";
 j+="\"status\":\""+statusText()+"\",";
 j+="\"liquid\":\""+String(config.liquid)+"\"}";
 server.send(200,"application/json",j);
}

void roomsAPI(){
 String j="[";
 for(int i=1;i<=3;i++){
  j+="{\"room\":"+String(i)+",";
  if(i==1){
   j+="\"mode\":\"REAL\",\"level\":"+String(level,0)+",\"status\":\""+statusText()+"\"}";
  }else{
   j+="\"mode\":\"SIMULATION\",\"level\":"+String(rooms[i].level)+",\"status\":\""+rooms[i].status+"\"}";
  }
  if(i<3)j+=",";
 }
 j+="]";
 server.send(200,"application/json",j);
}

void configAPI(){
 strncpy(config.liquid,server.arg("liquid").c_str(),31);
 config.capacity=server.arg("capacity").toInt();
 config.warning=server.arg("warning").toFloat();
 config.critical=server.arg("critical").toFloat();
 saveConfig();
 server.send(200,"application/json","{\"success\":true}");
}

void simulationCommand(String c){
 if(c.length()<2)return;
 int room=c.substring(1).toInt();
 if(room<1||room>3)return;
 char state=c.charAt(0);
 if(state=='N'){rooms[room].level=80;rooms[room].status="NORMAL";}
 if(state=='L'){rooms[room].level=20;rooms[room].status="LOW";}
 if(state=='C'){rooms[room].level=5;rooms[room].status="CRITICAL";}
 Serial.println("Simulation updated Room "+String(room));
}

void setup(){
 Serial.begin(115200);
 EEPROM.begin(EEPROM_SIZE);
 loadConfig();
 lcd.begin(16,2);
 WiFi.softAP(ssid,password);
 server.on("/status",HTTP_GET,statusAPI);
 server.on("/rooms",HTTP_GET,roomsAPI);
 server.on("/config",HTTP_POST,configAPI);
 server.begin();
}

void loop(){
 server.handleClient();
 if(Serial.available())simulationCommand(Serial.readStringUntil('\n'));
 adcValue=readSensor();
 level=calculateLevel(adcValue);
 lcd.clear();
 lcd.print(config.liquid);
 lcd.setCursor(0,1);
 lcd.print("L:");lcd.print(level,0);lcd.print("% ");lcd.print(statusText());
 delay(500);
}
