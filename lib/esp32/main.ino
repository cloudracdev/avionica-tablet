#include <Wire.h>                // Nativa ESP
#include <Adafruit_BMP085.h>     // 1.2.4
#include "SPI.h"                 // Nativa ESP
#include "SparkFunLSM6DS3.h"     // 1.0.3
#include <TinyGPS++.h>           // 1.0.3
#include <ArduinoJson.h>         // 7.3.1
#include <WiFi.h>                // Nativa ESP
#include <WebSocketsServer.h>    // WebSockets by Markus Sattler
#include <Adafruit_Sensor.h>     // 1.1.15
#include <Adafruit_HMC5883_U.h>  // 1.2.3

// ==================== DEFINIÇÕES ====================
#define address_HMC5883 0x1E
#define Register_ID 0
#define Register_2D 0x2D
#define Register_X0 0x32
#define Register_X1 0x33
#define Register_Y0 0x34
#define Register_Y1 0x35
#define Register_Z0 0x36
#define Register_Z1 0x37
#define Addr 0x69           // L3G4200D
#define ADXAddress 0x53     // ADXL345
#define RXD2 17
#define TXD2 16
#define CTRL_REG1 0x20
#define CTRL_REG2 0x21
#define CTRL_REG3 0x22
#define CTRL_REG4 0x23
#define CTRL_REG5 0x24

// ==================== CONFIGURAÇÃO WiFi ====================
const char* ssid = "AVIONICA";
const char* password = "12345678";

// ==================== OBJETOS ====================
WebSocketsServer webSocket = WebSocketsServer(81);
HardwareSerial neogps(1);
Adafruit_BMP085 bmp;
TinyGPSPlus gps;
Adafruit_HMC5883_Unified mag = Adafruit_HMC5883_Unified(12345);
LSM6DS3 myIMU(I2C_MODE, 0x6B);

// ==================== VARIÁVEIS GLOBAIS ====================
// Telemetria
float roll, pitch, rollF, pitchF = 0, LAT, LON;
float height2 = 0, height_dif = 0;
float lat1, lat2 = 0, latdif, lon2 = 0, lon1, londif;
float a, d, c;
int reading = 0;
int val = 0;
float X0, X1, X_out, Y0, Y1, Y_out, Z1, Z0, Z_out, ang2 = 0;
double Xg, Yg, Zg;
float headingDegrees = 0;
float Ang_dif = 0;

// Giroscópio L3G4200D
int L3G4200D_Address = 105;
int x, y, z;

// Acelerômetro ADXL345
int ACreading = 0;
int ACX0, ACX1, ACX_out;
int ACY0, ACY1, ACY_out;
int ACZ1, ACZ0, ACZ_out;
double ACXg, ACYg, ACZg;

// Variômetro
float altitude_anterior = 0;
float altitude_atual = 0;
unsigned long tempo_anterior_vario = 0;
float variometro = 0;
const float ALPHA_FILTRO = 0.3;

// Timing
unsigned long lastUpdate = 0;
unsigned long previousMillis_turn = 0;
const int UPDATE_INTERVAL = 50;

// ==================== FUNÇÕES AUXILIARES I2C ====================
void writeRegister(int deviceAddress, byte address, byte val) {
  Wire.beginTransmission(deviceAddress);
  Wire.write(address);
  Wire.write(val);
  Wire.endTransmission();
}

int readRegister(int deviceAddress, byte address) {
  int v;
  Wire.beginTransmission(deviceAddress);
  Wire.write(address);
  Wire.endTransmission();
  Wire.requestFrom(deviceAddress, 1);
  while (!Wire.available()) {
    // waiting
  }
  v = Wire.read();
  return v;
}

// ==================== GIROSCÓPIO L3G4200D ====================
int setupL3G4200D(int scale) {
  writeRegister(L3G4200D_Address, CTRL_REG1, 0b00001111);
  writeRegister(L3G4200D_Address, CTRL_REG2, 0b00000000);
  writeRegister(L3G4200D_Address, CTRL_REG3, 0b00001000);
  if (scale == 250) {
    writeRegister(L3G4200D_Address, CTRL_REG4, 0b00000000);
  } else if (scale == 500) {
    writeRegister(L3G4200D_Address, CTRL_REG4, 0b00010000);
  } else {
    writeRegister(L3G4200D_Address, CTRL_REG4, 0b00110000);
  }
  writeRegister(L3G4200D_Address, CTRL_REG5, 0b00000000);
  return 0;
}

void getGyroValues() {
  byte xMSB = readRegister(L3G4200D_Address, 0x29);
  byte xLSB = readRegister(L3G4200D_Address, 0x28);
  x = ((xMSB << 8) | xLSB);
  byte yMSB = readRegister(L3G4200D_Address, 0x2B);
  byte yLSB = readRegister(L3G4200D_Address, 0x2A);
  y = ((yMSB << 8) | yLSB);
  byte zMSB = readRegister(L3G4200D_Address, 0x2D);
  byte zLSB = readRegister(L3G4200D_Address, 0x2C);
  z = ((zMSB << 8) | zLSB);
}

void giroscopio() {
  unsigned int data[6];
  for(int i = 0; i < 6; i++) {
    Wire.beginTransmission(Addr);
    Wire.write((40 + i));
    Wire.endTransmission();
    Wire.requestFrom(Addr, 1);
    
    if(Wire.available() == 1) {
      data[i] = Wire.read();
    }
  }
  
  // Converter os dados
  x = data[1] * 256 + data[0];
  y = data[3] * 256 + data[2];
  z = data[5] * 256 + data[4];
}

// ==================== ACELERÔMETRO ADXL345 ====================
void acelerometro() {
  // Leitura sequencial dos 6 bytes (X, Y, Z - 2 bytes cada)
  Wire.beginTransmission(ADXAddress);
  Wire.write(Register_X0);
  Wire.endTransmission(false);
  Wire.requestFrom((uint16_t)ADXAddress, (uint8_t)6, (bool)true);
  
  if(Wire.available() >= 6) {
    ACX0 = Wire.read();
    ACX1 = Wire.read();
    ACY0 = Wire.read();
    ACY1 = Wire.read();
    ACZ0 = Wire.read();
    ACZ1 = Wire.read();
    
    ACX_out = (ACX1 << 8) | ACX0;
    ACY_out = (ACY1 << 8) | ACY0;
    ACZ_out = (ACZ1 << 8) | ACZ0;
    
    // Converter para g
    ACXg = ACX_out / 256.0;
    ACYg = ACY_out / 256.0;
    ACZg = ACZ_out / 256.0;
  }
}

// ==================== BÚSSOLA HMC5883L ====================
void bussola() {
  sensors_event_t event;
  mag.getEvent(&event);
  
  float heading = atan2(event.magnetic.y, event.magnetic.x);
  float declinationAngle = 0.349; // Curitiba
  heading += declinationAngle;
  
  if (heading < 0)
    heading += 2 * PI;
  
  if (heading > 2 * PI)
    heading -= 2 * PI;
  
  headingDegrees = heading * 180 / M_PI;
}

// ==================== LSM6DS3 ====================
void lsm() {
  // Leitura do acelerômetro LSM6DS3
  X_out = myIMU.readFloatAccelX();
  Y_out = myIMU.readFloatAccelY();
  Z_out = myIMU.readFloatAccelZ();
}

void pitchandroll() {
  // Usar dados do LSM6DS3 para calcular pitch e roll
  lsm(); // Atualizar X_out, Y_out, Z_out
  
  roll = atan(Y_out / sqrt(pow(X_out, 2) + pow(Z_out, 2))) * 180 / PI;
  pitch = atan(-1 * X_out / sqrt(pow(Y_out, 2) + pow(Z_out, 2))) * 180 / PI;
  
  // Filtro passa-baixa
  rollF = 0.94 * rollF + 0.06 * roll;
  pitchF = 0.94 * pitchF + 0.06 * pitch;
  
  // Calcular diferença angular para coordenador de curva
  float ang1 = roll;
  unsigned long currentMillis_turn = millis();
  Ang_dif = ang2 - ang1;
  previousMillis_turn = currentMillis_turn;
  ang2 = ang1;
}

// ==================== GPS ====================
void latilon() {
  boolean newData = false;
  
  // Processar dados do GPS
  for (unsigned long start = millis(); millis() - start < 100;) {
    while (neogps.available()) {
      if (gps.encode(neogps.read())) {
        newData = true;
      }
    }
  }
  
  // Atualizar coordenadas se houver dados novos
  if (newData && gps.location.isValid()) {
    LAT = gps.location.lat();
    LON = gps.location.lng();
  }
}

// ==================== BMP085/180 (BARÔMETRO) ====================
// Pressão ao nível do mar em Curitiba (ajuste conforme sua localização)
// Valor padrão: 101325 Pa (1013.25 hPa)
// Para Curitiba (altitude ~900m): aproximadamente 90800 Pa
const float PRESSAO_NIVEL_MAR = 101325; // Ajuste este valor conforme necessário

void temperatura() {
  // Função mantida para compatibilidade
  // Os dados são lidos diretamente no loop principal
}

float calcAltitude(float pressure) {
  // Fórmula barométrica padrão
  float A = pressure / PRESSAO_NIVEL_MAR;
  float B = 1.0 / 5.25588;
  float C = pow(A, B);
  C = C - 1.0;
  C = C / 0.0000225577;
  return C;
}

// ==================== VARIÔMETRO ====================
void calcularVariometro() {
  // Usar altitude com correção para nível do mar local
  altitude_atual = bmp.readAltitude(PRESSAO_NIVEL_MAR);
  unsigned long tempo_atual = millis();
  
  if (tempo_anterior_vario > 0) {
    float delta_altitude = altitude_atual - altitude_anterior;
    float delta_tempo = (tempo_atual - tempo_anterior_vario) / 1000.0;
    
    if (delta_tempo > 0) {
      float vario_instantaneo = delta_altitude / delta_tempo;
      variometro = ALPHA_FILTRO * vario_instantaneo + (1 - ALPHA_FILTRO) * variometro;
    }
  } else {
    variometro = 0;
  }
  
  altitude_anterior = altitude_atual;
  tempo_anterior_vario = tempo_atual;
  
  // Calcular variômetro em pés/min (compatível com código original)
  float height1 = altitude_atual * 3.28084; // metros para pés
  height_dif = (height1 - height2) * 60;
  height2 = height1;
}

// ==================== WEBSOCKET ====================
void webSocketEvent(uint8_t num, WStype_t type, uint8_t * payload, size_t length) {
  switch(type) {
    case WStype_DISCONNECTED:
      Serial.printf("❌ Cliente [%u] desconectado\n", num);
      break;
      
    case WStype_CONNECTED: {
      IPAddress ip = webSocket.remoteIP(num);
      Serial.printf("✅ Cliente [%u] conectado de %d.%d.%d.%d\n", 
                    num, ip[0], ip[1], ip[2], ip[3]);
      webSocket.sendTXT(num, "{\"status\":\"conectado\"}");
      break;
    }
    
    case WStype_TEXT:
      Serial.printf("📥 Recebido de [%u]: %s\n", num, payload);
      break;
      
    case WStype_BIN:
      Serial.printf("📦 Dados binários recebidos de [%u], tamanho: %u\n", num, length);
      break;
      
    case WStype_ERROR:
      Serial.printf("⚠️ Erro no WebSocket [%u]\n", num);
      break;
  }
}

// ==================== SETUP ====================
void setup() {
  Serial.begin(115200);
  delay(100);
  Serial.println("\n🚀 Iniciando ESP32 Sistema Aviônico...");

  // ========== CONFIGURAR WiFi ACCESS POINT ==========
  WiFi.softAP(ssid, password);
  IPAddress IP = WiFi.softAPIP();
  
  Serial.println("✅ Access Point criado!");
  Serial.print("📡 SSID: ");
  Serial.println(ssid);
  Serial.print("🔑 Senha: ");
  Serial.println(password);
  Serial.print("🌐 IP: ");
  Serial.println(IP);
  Serial.print("🔌 WebSocket: ws://");
  Serial.print(IP);
  Serial.println(":81");

  // ========== INICIAR WEBSOCKET ==========
  webSocket.begin();
  webSocket.onEvent(webSocketEvent);
  Serial.println("✅ WebSocket servidor na porta 81");

  // ========== INICIALIZAR I2C ==========
  Wire.begin();
  delay(100);
  Serial.println("✅ I2C iniciado");

  // ========== INICIALIZAR SENSORES ==========
  
  // BMP085/180 (Barômetro/Altímetro)
  if (!bmp.begin()) {
    Serial.println("❌ Sensor BMP085 não encontrado!");
  } else {
    Serial.println("✅ BMP085 iniciado");
  }

  // HMC5883L (Bússola)
  if (!mag.begin()) {
    Serial.println("❌ Bússola HMC5883 não encontrada!");
  } else {
    Serial.println("✅ Bússola HMC5883 iniciada");
  }

  // ADXL345 (Acelerômetro)
  Wire.beginTransmission(ADXAddress);
  Wire.write(Register_2D);
  Wire.write(8); // Measuring enable
  Wire.endTransmission();
  Serial.println("✅ Acelerômetro ADXL345 iniciado");

  // L3G4200D (Giroscópio)
  Wire.beginTransmission(Addr);
  Wire.write(0x20);
  Wire.write(0x0F); // Normal mode, X, Y, Z-Axis enabled
  Wire.endTransmission();
  
  Wire.beginTransmission(Addr);
  Wire.write(0x23);
  Wire.write(0x30); // Continuous update, FSR = 2000dps
  Wire.endTransmission();
  
  setupL3G4200D(2000);
  Serial.println("✅ Giroscópio L3G4200D iniciado");

  // LSM6DS3 (Acelerômetro/Giroscópio 6DOF)
  if (myIMU.begin() != 0) {
    Serial.println("❌ LSM6DS3 erro na inicialização");
  } else {
    Serial.println("✅ LSM6DS3 iniciado");
  }

  // GPS NEO-6M
  neogps.begin(9600, SERIAL_8N1, RXD2, TXD2);
  Serial.println("✅ GPS NEO-6M iniciado");

  // ========== INICIALIZAR VARIÁVEIS ==========
  // ========== INICIALIZAR VARIÁVEIS COM ALTITUDE CORRIGIDA ==========
  altitude_anterior = bmp.readAltitude(PRESSAO_NIVEL_MAR);
  tempo_anterior_vario = millis();
  height2 = bmp.readAltitude(PRESSAO_NIVEL_MAR) * 3.28084;


  Serial.println("\n🎯 Sistema pronto! Aguardando conexões...");
  Serial.println("==================================================\n");
  delay(500);
}

// ==================== LOOP PRINCIPAL ====================
void loop() {
  webSocket.loop();

  // Enviar dados a cada 50ms (20Hz)
  if (millis() - lastUpdate > UPDATE_INTERVAL) {
    lastUpdate = millis();

    // ========== LEITURA DOS SENSORES ==========
    acelerometro();      // ADXL345
    bussola();           // HMC5883L
    giroscopio();        // L3G4200D
    pitchandroll();      // LSM6DS3 + cálculo pitch/roll
    latilon();           // GPS
    calcularVariometro(); // BMP085 + cálculo variômetro

    // ========== CRIAR JSON ==========
    StaticJsonDocument<768> doc;
    
    // Six-Pack (Instrumentos principais)
    doc["velocidade"] = gps.speed.kmph();
    doc["altitude"] = bmp.readAltitude(PRESSAO_NIVEL_MAR);
    doc["altitude_ft"] = bmp.readAltitude(PRESSAO_NIVEL_MAR) * 3.28084;
    doc["heading"] = headingDegrees;
    doc["pitch"] = pitch;
    doc["roll"] = roll;
    doc["variometro"] = variometro;          // m/s
    doc["variometro_ft"] = height_dif;       // pés/min
    
    // Coordenador de curva
    doc["coordcurva"] = Ang_dif;
    
    // Dados ambientais
    doc["temperatura"] = bmp.readTemperature();
    doc["pressao"] = bmp.readPressure();
    
    // GPS
    doc["lat"] = LAT;
    doc["lng"] = LON;
    doc["satelites"] = gps.satellites.value();
    doc["hdop"] = gps.hdop.value() / 100.0;
    
    // Giroscópio L3G4200D
    doc["gyro_x"] = x;
    doc["gyro_y"] = y;
    doc["gyro_z"] = z;
    
    // Acelerômetro ADXL345
    doc["acel_x"] = ACXg;
    doc["acel_y"] = ACYg;
    doc["acel_z"] = ACZg;
    
    // LSM6DS3
    doc["lsm_ax"] = X_out;
    doc["lsm_ay"] = Y_out;
    doc["lsm_az"] = Z_out;
    doc["lsm_gx"] = myIMU.readFloatGyroX();
    doc["lsm_gy"] = myIMU.readFloatGyroY();
    doc["lsm_gz"] = myIMU.readFloatGyroZ();

    String jsonString;
    serializeJson(doc, jsonString);

    // ========== ENVIAR PARA CLIENTES ==========
    webSocket.broadcastTXT(jsonString);
    
    // Log opcional (descomente para debug)
    // Serial.println(jsonString);
  }
  
  yield();
}