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
unsigned long lastSensorCycle=0;
unsigned long lastSample=0;
long sampleSum=0;
int sampleCount=0;
bool sampling=false;
String serialCommand;
bool serialOverflow=false;
int lastStationCount=-1;

void loadConfig(){
 EEPROM.get(0,config);
 if(config.liquid[0]=='\0'||static_cast<unsigned char>(config.liquid[0])==0xFF){strcpy(config.liquid,"Not Set");config.capacity=0;config.warning=25;config.critical=10;}
 config.liquid[31]='\0';
}

// Escape configuration text so a quote in a bottle name cannot break JSON
// and make the app report a lost connection.
String jsonText(const String& value){
 String result="\"";
 for(unsigned int i=0;i<value.length();i++){
  unsigned char c=value[i];
  if(c=='\"'||c=='\\'){result+='\\';result+=char(c);}
  else if(c<0x20){char escaped[7];snprintf(escaped,sizeof(escaped),"\\u%04x",c);result+=escaped;}
  else result+=char(c);
 }
 return result+"\"";
}

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
  j+="\"name\":"+jsonText(rooms[i].name)+",";
  j+="\"liquid\":"+jsonText(i==1?String(config.liquid):rooms[i].liquid)+",";
  j+="\"capacity\":"+(i==1?String(config.capacity):String(rooms[i].capacity))+",";
  j+="\"mode\":"+jsonText(i==1?"REAL":"SIMULATION")+",";
  j+="\"level\":"+(i==1?String(level,0):String(rooms[i].level))+",";
  j+="\"status\":\""+(i==1?statusText():rooms[i].status)+"\"}";
  if(i<3)j+=",";
 }
 j+="]";
 server.send(200,"application/json",j);
}

void statusAPI(){
 String j="{\"level\":"+String(level,0);
 j+=",\"adc\":"+String(adcValue);
 j+=",\"status\":"+jsonText(statusText());
 j+=",\"liquid\":"+jsonText(String(config.liquid));
 j+=",\"capacityMl\":"+String(config.capacity);
 j+=",\"warningThreshold\":"+String(config.warning);
 j+=",\"criticalThreshold\":"+String(config.critical)+"}";
 server.send(200,"application/json",j);
}

void configAPI(){
 strncpy(config.liquid,server.arg("liquid").c_str(),31);
 config.liquid[31]='\0';
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
 Serial.println();Serial.println("LiquidMonitor boot");
 Serial.println(ESP.getResetReason());
 lcd.begin(16,2);
 WiFi.persistent(false);
 WiFi.mode(WIFI_AP);
 WiFi.setSleepMode(WIFI_NONE_SLEEP);
 IPAddress ip(192,168,4,1);
 if(!WiFi.softAPConfig(ip,ip,IPAddress(255,255,255,0)) ||
    !WiFi.softAP(ssid,password)){
  Serial.println("Failed to start LiquidMonitor Wi-Fi");
 }
 Serial.print("ESP address: ");Serial.println(WiFi.softAPIP());
 server.on("/rooms",HTTP_GET,roomsAPI);
 server.on("/status",HTTP_GET,statusAPI);
 server.on("/config",HTTP_POST,configAPI);
 server.begin();
 lastSensorCycle=millis()-500;
}

void loop(){
 // HTTP must be serviced continuously, including while sampling the sensor.
 server.handleClient();
 for(int i=0;i<32 && Serial.available();i++){
  char c=Serial.read();
  if(c=='\n'){
   if(!serialOverflow)simulationCommand(serialCommand);
   serialCommand="";serialOverflow=false;
  }else if(c!='\r'){
   if(serialCommand.length()<32)serialCommand+=c;
   else serialOverflow=true;
  }
 }

 unsigned long now=millis();
 if(!sampling && now-lastSensorCycle>=500){
  sampling=true;sampleSum=0;sampleCount=0;
  lastSensorCycle=now;lastSample=now-2;
 }
 if(sampling && now-lastSample>=2){
  lastSample=now;sampleSum+=analogRead(SENSOR_PIN);sampleCount++;
  if(sampleCount==20){
   sampling=false;adcValue=sampleSum/20;level=calculateLevel(adcValue);
   // Overwrite and pad each row without clearing the LCD on every sample.
   lcd.setCursor(0,0);
   String row=String(config.liquid).substring(0,16);
   while(row.length()<16)row+=' ';
   lcd.print(row);
   lcd.setCursor(0,1);
   row="L:"+String(level,0)+"% "+statusText();
   while(row.length()<16)row+=' ';
   lcd.print(row.substring(0,16));
   int stations=WiFi.softAPgetStationNum();
   if(stations!=lastStationCount){
    lastStationCount=stations;
    Serial.printf("Wi-Fi clients: %d\n",stations);
   }
  }
 }
 yield();
}
