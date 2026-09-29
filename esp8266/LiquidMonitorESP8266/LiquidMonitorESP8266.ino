/* Smart Liquid Level Monitor
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

ESP8266WebServer server(80);
const char* ssid="LiquidMonitor";
const char* password="liquid123";

struct BottleConfig{char liquid[32]; int capacity; float warning; float critical;};
BottleConfig config={"Not Set",0,25,10};

struct SimRoom{String name; String liquid; int capacity; int level; String status;};
SimRoom rooms[4]={
 {"","",0,0,""},
 {"Main Bottle","Normal Saline",500,72,"NORMAL"},
 {"ICU Bed 2","Glucose 5%",1000,80,"NORMAL"},
 {"Emergency Room","Normal Saline",500,5,"CRITICAL"}
};

float level=0;
int adcValue=0;

void loadConfig(){
 EEPROM.get(0,config);
 if(config.liquid[0]=='\0'||config.liquid[0]==0xFF){strcpy(config.liquid,"Not Set");config.capacity=0;config.warning=25;config.critical=10;}
}

int readSensor(){long s=0;for(int i=0;i<20;i++){s+=analogRead(SENSOR_PIN);delay(2);}return s/20;}

float calculateLevel(int adc){
 if(adc<=ADC_0)return 0;
 if(adc<=ADC_25)return (adc-ADC_0)*25.0/(ADC_25-ADC_0);
 if(adc<=ADC_50)return 25+(adc-ADC_25)*25.0/(ADC_50-ADC_25);
 if(adc<=ADC_75)return 50+(adc-ADC_50)*25.0/(ADC_75-ADC_50);
 if(adc<=ADC_100)return 75+(adc-ADC_75)*25.0/(ADC_100-ADC_75);
 return 100;
}

String statusText(){if(level<=config.critical)return "CRITICAL";if(level<=config.warning)return "LOW";return "NORMAL";}

void roomsAPI(){
 String j="[";
 for(int i=1;i<=3;i++){
  j+="{\"room\":"+String(i)+",";
  j+="\"name\":\""+rooms[i].name+"\",";
  j+="\"liquid\":\""+(i==1?String(config.liquid):rooms[i].liquid)+"\",";
  j+="\"capacity\":"+(i==1?String(config.capacity):String(rooms[i].capacity))+",";
  j+="\"mode\":\""+(i==1?"REAL":"SIMULATION")+"\",";
  j+="\"level\":"+(i==1?String(level,0):String(rooms[i].level))+",";
  j+="\"status\":\""+(i==1?statusText():rooms[i].status)+"\"}";
  if(i<3)j+=",";
 }
 j+="]";
 server.send(200,"application/json",j);
}

void statusAPI(){server.send(200,"application/json","{\"level\":"+String(level,0)+"}");}

void configAPI(){
 strncpy(config.liquid,server.arg("liquid").c_str(),31);
 config.capacity=server.arg("capacity").toInt();
 config.warning=server.arg("warning").toFloat();
 config.critical=server.arg("critical").toFloat();
 server.send(200,"application/json","{\"success\":true}");
}

void simulationCommand(String c){
 if(c.length()<2)return;
 int r=c.substring(1).toInt(); if(r<2||r>3)return;
 if(c[0]=='N'){rooms[r].level=80;rooms[r].status="NORMAL";}
 if(c[0]=='L'){rooms[r].level=20;rooms[r].status="LOW";}
 if(c[0]=='C'){rooms[r].level=5;rooms[r].status="CRITICAL";}
 Serial.println("Updated Room "+String(r));
}

void setup(){
 Serial.begin(115200);EEPROM.begin(EEPROM_SIZE);loadConfig();
 lcd.begin(16,2);
 WiFi.softAP(ssid,password);
 server.on("/rooms",HTTP_GET,roomsAPI);
 server.on("/status",HTTP_GET,statusAPI);
 server.on("/config",HTTP_POST,configAPI);
 server.begin();
}

void loop(){
 server.handleClient();
 if(Serial.available())simulationCommand(Serial.readStringUntil('\n'));
 adcValue=readSensor();level=calculateLevel(adcValue);
 lcd.clear();lcd.print(config.liquid);lcd.setCursor(0,1);lcd.print("L:");lcd.print(level,0);lcd.print("% ");lcd.print(statusText());
 delay(500);
}
