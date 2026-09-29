/*
 Smart Liquid Level Monitor
 ESP8266 NodeMCU V3
 Persistent bottle configuration using EEPROM
*/

#include <ESP8266WiFi.h>
#include <ESP8266WebServer.h>
#include <LiquidCrystal.h>
#include <EEPROM.h>

LiquidCrystal lcd(D1, D2, D5, D6, D7, D0);

#define SENSOR_PIN A0
#define EEPROM_SIZE 256

#define ADC_0 14
#define ADC_25 540
#define ADC_50 586
#define ADC_75 605
#define ADC_100 630

const char* ssid = "LiquidMonitor";
const char* password = "liquid123";

ESP8266WebServer server(80);

int adcValue = 0;
float level = 0;

String liquid = "Not Set";
int capacity = 0;
float warning = 25;
float critical = 10;

void saveConfig(){
  EEPROM.put(0, liquid);
  EEPROM.put(80, capacity);
  EEPROM.put(90, warning);
  EEPROM.put(100, critical);
  EEPROM.commit();
}

void loadConfig(){
  EEPROM.get(0, liquid);
  EEPROM.get(80, capacity);
  EEPROM.get(90, warning);
  EEPROM.get(100, critical);

  if(liquid.length() == 0 || liquid.length() > 40){
    liquid = "Not Set";
    capacity = 0;
    warning = 25;
    critical = 10;
  }
}

int readSensor(){
  long sum = 0;
  for(int i=0;i<20;i++){
    sum += analogRead(SENSOR_PIN);
    delay(2);
  }
  return sum / 20;
}

float calculateLevel(int adc){
  if(adc <= ADC_0) return 0;
  if(adc <= ADC_25) return (float)(adc-ADC_0)/(ADC_25-ADC_0)*25;
  if(adc <= ADC_50) return 25+(float)(adc-ADC_25)/(ADC_50-ADC_25)*25;
  if(adc <= ADC_75) return 50+(float)(adc-ADC_50)/(ADC_75-ADC_50)*25;
  if(adc <= ADC_100) return 75+(float)(adc-ADC_75)/(ADC_100-ADC_75)*25;
  return 100;
}

String statusText(){
  if(level <= critical) return "CRITICAL";
  if(level <= warning) return "LOW";
  return "NORMAL";
}

void statusAPI(){
  String json = "{";
  json += "\"adc\":" + String(adcValue) + ",";
  json += "\"level\":" + String(level,1) + ",";
  json += "\"status\":\"" + statusText() + "\",";
  json += "\"liquid\":\"" + liquid + "\",";
  json += "\"capacityMl\":" + String(capacity) + ",";
  json += "\"warningThreshold\":" + String(warning) + ",";
  json += "\"criticalThreshold\":" + String(critical);
  json += "}";

  server.send(200,"application/json",json);
}

void configAPI(){
  if(!server.hasArg("liquid") || !server.hasArg("capacity") || !server.hasArg("warning") || !server.hasArg("critical")){
    server.send(400,"application/json","{\"error\":\"Missing data\"}");
    return;
  }

  liquid = server.arg("liquid");
  capacity = server.arg("capacity").toInt();
  warning = server.arg("warning").toFloat();
  critical = server.arg("critical").toFloat();

  saveConfig();

  server.send(200,"application/json","{\"success\":true}");
}

void setup(){
  Serial.begin(115200);

  EEPROM.begin(EEPROM_SIZE);
  loadConfig();

  lcd.begin(16,2);

  WiFi.softAP(ssid,password);

  server.on("/status",HTTP_GET,statusAPI);
  server.on("/config",HTTP_POST,configAPI);
  server.begin();

  lcd.print("WiFi Ready");
}

void loop(){
  server.handleClient();

  adcValue = readSensor();
  level = calculateLevel(adcValue);

  lcd.clear();
  lcd.setCursor(0,0);
  lcd.print(liquid.substring(0,16));

  lcd.setCursor(0,1);
  lcd.print("L:");
  lcd.print(level,0);
  lcd.print("% ");
  lcd.print(statusText());

  delay(500);
}
