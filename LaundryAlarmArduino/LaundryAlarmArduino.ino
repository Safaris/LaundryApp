#include <Wire.h>

#define CTRL_REG1 0x20
#define CTRL_REG2 0x21
#define CTRL_REG3 0x22
#define CTRL_REG4 0x23
#define CTRL_REG5 0x24

// I2C address of the L3G4200D.
// Use I2C scanner to find this value!
int L3G4200D_Address = 0x69;
int BUTTON_PIN = 2;

boolean running;

// Delta angles (raw input from gyro)
int x = 0;
int y = 0;
int z = 0;

// Calibration values
int gyroLowX = 0;
int gyroLowY = -250;
int gyroLowZ = -238;
int gyroHighX = 164;
int gyroHighY = 250;
int gyroHighZ = 228;

void setup()
{
  pinMode(BUTTON_PIN, INPUT);
  
  Wire.begin();
  Serial.begin(9600);
  
  running = false;

  Serial.println("[loading]");
  
  setupL3G4200D(250); // Configure L3G4200  - 250, 500 or 2000 deg/sec
  
  delay(250); // wait for the sensor to be ready
  
  Serial.println("[loaded]");
}

void loop()
{
  getGyroValues();
  
  if (Serial.available()) {
    char val = Serial.read();
    if(val == '!') {
      running = false;
    }
  }
  
  if(digitalRead(BUTTON_PIN) && !running) {
    Serial.println("[start]");
    running = true;
  }
  
  if(running) {
    sendJson();
  }
  
  delay(20);
}

void updateAngle()
{
  getGyroValues();
}

void calibrate()
{
  Serial.println("Calibrating gyro, don't move!");
  for(int i = 0; i < 1000; i++) {
    getGyroValues();

    if(x > gyroHighX)
      gyroHighX = x;
    else if(x < gyroLowX)
      gyroLowX = x;

    if(y > gyroHighY)
      gyroHighY = y;
    else if(y < gyroLowY)
      gyroLowY = y;

    if(z > gyroHighZ)
      gyroHighZ = z;
    else if(z < gyroLowZ)
      gyroLowZ = z;
    
    delay(10);
  }
  Serial.println("Calibration complete.");
}

// Print angles to Serial (for use in Processing, for example)
void sendJson() {
    char json[100];
    sprintf(json, "{\"x\":%d,\"y\":%d,\"z\":%d}", x, y, z);
    Serial.println(json);
}

void getGyroValues() {
  byte xMSB = readRegister(L3G4200D_Address, 0x29);
  byte xLSB = readRegister(L3G4200D_Address, 0x28);
  int tmpX = ((xMSB << 8) | xLSB);
  if(tmpX >= gyroHighX || tmpX <= gyroLowX) {
    x = tmpX;
  } else {
    x = 0;
  }

  byte yMSB = readRegister(L3G4200D_Address, 0x2B);
  byte yLSB = readRegister(L3G4200D_Address, 0x2A);
  int tmpY = ((yMSB << 8) | yLSB);
  if(tmpY >= gyroHighY || tmpY <= gyroLowY) {
    y = tmpY;
  } else {
    y = 0;
  }

  byte zMSB = readRegister(L3G4200D_Address, 0x2D);
  byte zLSB = readRegister(L3G4200D_Address, 0x2C);
  int tmpZ = ((zMSB << 8) | zLSB);
  if(tmpZ >= gyroHighZ || tmpZ <= gyroLowZ) {
    z = tmpZ;
  } else {
    z = 0;
  }
}

int setupL3G4200D(int scale) {
  writeRegister(L3G4200D_Address, CTRL_REG1, 0b00001111);
  writeRegister(L3G4200D_Address, CTRL_REG2, 0b00000000);
  writeRegister(L3G4200D_Address, CTRL_REG3, 0b00001000);

  if(scale == 250) {
    writeRegister(L3G4200D_Address, CTRL_REG4, 0b00000000);
  } else if(scale == 500) {
    writeRegister(L3G4200D_Address, CTRL_REG4, 0b00010000);
  } else {
    writeRegister(L3G4200D_Address, CTRL_REG4, 0b00110000);
  }

  writeRegister(L3G4200D_Address, CTRL_REG5, 0b00000000);
}

void writeRegister(int deviceAddress, byte address, byte val)
{
    Wire.beginTransmission(deviceAddress); // start transmission to device 
    Wire.write(address);       // send register address
    Wire.write(val);         // send value to write
    Wire.endTransmission();     // end transmission
}

int readRegister(int deviceAddress, byte address)
{
    int v;
    Wire.beginTransmission(deviceAddress);
    Wire.write(address); // register to read
    Wire.endTransmission();

    Wire.requestFrom(deviceAddress, 1); // read a byte

    while(!Wire.available()) {
        // waiting
    }
    v = Wire.read();
    return v;
}
