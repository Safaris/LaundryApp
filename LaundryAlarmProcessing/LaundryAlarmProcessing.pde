import org.json.JSONObject;
import processing.serial.*;
import com.github.sendgrid.SendGrid;
import java.util.Date;
import java.text.SimpleDateFormat;

// User information
final static String USER_EMAIL = "shoffing@gmail.com";
final static String USER_PHONE = "6093542426@vtext.com";
final static String USER_TWITTER = "shoffing";

// Gyro sensitivity
final static int SENSITIVITY = 300;

Serial myPort;

boolean running, loading;
long lastVibrationTime;

PFont lobsterFont, arvoFont;

void setup()
{
    size(800, 800);
    
    loading = true;
    
    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil(10);
    
    lobsterFont = createFont("Lobster.ttf", 128);
    arvoFont = createFont("Arvo-Regular.ttf", 48);

    lastVibrationTime = millis();
}

void draw()
{
    background(255, 255, 157);

    int w = width;
    int h = height;
    int hw = w/2;
    int hh = h/2;

    textAlign(CENTER, CENTER);
    fill(255);
    if(loading) {
        fill(255, 97, 56);
        textFont(arvoFont);
        text("loading...", hw, hh);
    } else if(running) {
        // Draw progress bar
        float timeRatio = ((millis() - lastVibrationTime) / 1000.0) / 30.0;

        fill(190*timeRatio + 121*(1-timeRatio),
             235*timeRatio + 189*(1-timeRatio),
             159*timeRatio + 143*(1-timeRatio));
        noStroke();
        rect(0, h * (1 - timeRatio), w, h * timeRatio);
        
        //
        
        if (millis() - lastVibrationTime < 30 * 1000) {
            fill(255, 97, 56);
            textFont(lobsterFont);
            text("Laundry\nin progress", hw, hh - 32);
        } else {
            sendLaundryDone();

            myPort.write('!');
            running = false;
        }
    } else {
        fill(255, 97, 56);
        textFont(arvoFont);
        text("- Put device on machine -\n- Start your laundry -\n- Press button -\n- Go about your life -", hw, hh);
    }
}

void sendLaundryDone()
{
    /*Begin SendGrid api*/
    SendGrid sendgrid = new SendGrid("jackjamieson", "HacktcnJ14");

    sendgrid.addTo(USER_EMAIL);
    sendgrid.setFrom("LaundryMachine@tcnj.edu");
    sendgrid.setSubject("Laundry is done!");
    sendgrid.setText("Hey, just wanted to let you know that your laundry is done.\nBetter pick it up before someone else does.\n");

    sendgrid.send();

    println("SENT EMAIL");

    //
    
    sendgrid = new SendGrid("jackjamieson", "HacktcnJ14");
    
    sendgrid.addTo(USER_PHONE);
    sendgrid.setFrom("LaundryMachine@tcnj.edu");
    sendgrid.setSubject("Laundry is done!");
    sendgrid.setText("Hey, your laundry is done. Go get it!");

    sendgrid.send();

    println("SENT PHONE");

    //

    ConfigurationBuilder cb = new ConfigurationBuilder();
    cb.setDebugEnabled(true);
    cb.setOAuthConsumerKey("dX57u33UBrGjIhQ8vKlw");
    cb.setOAuthConsumerSecret("FUu0Mc9urMOUd2GBQHPXmPhB4qu8kc0coMAAOJ57G0");
    cb.setOAuthAccessToken("2357203603-dfg66Wz8HVicsJaOGyV6zYSN7cl64gQ1vFOdkJS");
    cb.setOAuthAccessTokenSecret("yDEMPcu0xfgeLH03ZVLwaQf5Yxyf8ljr2LjMuy20mcYXl");
    Date dNow = new Date();
    SimpleDateFormat ft = new SimpleDateFormat ("E yyyy.MM.dd 'at' hh:mm:ss a zzz");

    TwitterFactory builder = new TwitterFactory(cb.build());
    Twitter twitter=builder.getInstance();
    UsersResources userres = twitter.users();
    try {
        User user = userres.showUser(USER_TWITTER);
        StatusUpdate latestStatus = new StatusUpdate("@" + USER_TWITTER + " Laundry is done! (" + ft.format(dNow) + ")");
        Status status = twitter.updateStatus(latestStatus);
    } catch(Exception e) {
        println(e);
    }

    println("SENT TWITTER");
}

void serialEvent(Serial port)
{
    String serialStr = port.readString();
    serialStr = serialStr.substring(0, serialStr.length() - 1);

    if (serialStr.charAt(0) == '{') {
        try {
            JSONObject json = new JSONObject(serialStr);
            int xv = json.getInt("x");
            int yv = json.getInt("y");
            int zv = json.getInt("z");

            if (abs(xv) + abs(yv) + abs(zv) > SENSITIVITY) {
                lastVibrationTime = millis();
            }
        } 
        catch(Exception e) {
            println("Exception cast on JSON stuff");
        }
    } else if(serialStr.indexOf("[start]") > -1) {
        running = true;
        lastVibrationTime = millis();
    } else if(serialStr.indexOf("[loading]") > -1) {
        loading = true;
    } else if(serialStr.indexOf("[loaded]") > -1) {
        loading = false;
    }
}

