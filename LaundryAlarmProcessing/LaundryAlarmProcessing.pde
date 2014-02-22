import org.json.JSONObject;

import processing.serial.*;

Serial myPort;

final static private int SENSITIVITY = 400;

boolean running;
long lastVibrationTime;

void setup()
{
    size(screenWidth, screenHeight);

    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil(10);

    lastVibrationTime = millis();
}

void draw()
{
    background(0);
    
    textSize(60);
    fill(255);
    if(running) {
        if(millis() - lastVibrationTime < 30 * 1000) {
            text("LAUNDRY IN PROGRESS", 20, screenHeight/2);
        } else {
            text("LAUNDRY IS DONE!", 20, screenHeight/2);
            myPort.write('!');
            running = false;
        }
        
        text((millis() - lastVibrationTime) / 1000.0, screenWidth/2, screenHeight/2);
    } else {
        text("PRESS BUTTON TO START", 20, screenHeight/2);
    }
}

void serialEvent(Serial port)
{
    String serialStr = port.readString();
    serialStr = serialStr.substring(0, serialStr.length() - 1);

    if (serialStr.charAt(0) == '{') {
        JSONObject json = new JSONObject(serialStr);
        int xv = json.getInt("x");
        int yv = json.getInt("y");
        int zv = json.getInt("z");

        if(abs(xv) + abs(yv) + abs(zv) > SENSITIVITY) {
            lastVibrationTime = millis();
        }
    } else if(serialStr.substring(0,7).equals("[start]")) {
        println("STARTING OMG");
        running = true;
    } else {
        println(serialStr);
    }
}

