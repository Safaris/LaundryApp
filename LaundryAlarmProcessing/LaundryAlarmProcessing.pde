import org.json.JSONObject;
import processing.serial.*;
import com.github.sendgrid.SendGrid;
import java.util.Date;
import java.text.SimpleDateFormat;


final static String USER_EMAIL = "shoffing@gmail.com";
final static String USER_PHONE = "6093542426@vtext.com";
final static String USER_TWITTER = "shoffing";

final static int SENSITIVITY = 300;

Serial myPort;

boolean running;
long lastVibrationTime;

void setup()
{
    size(800, 800);

    String portName = Serial.list()[0];
    myPort = new Serial(this, portName, 9600);
    myPort.bufferUntil(10);

    lastVibrationTime = millis();
}

void draw()
{
    background(0);
    
    textSize(20);
    fill(255);
    if(running) {
        if(millis() - lastVibrationTime < 30 * 1000) {
            text("LAUNDRY IN PROGRESS", 10, displayHeight/2);
        } else {
            text("LAUNDRY IS DONE!", 10, displayHeight/2);
            myPort.write('!');
            running = false;
            
            sendLaundryDone();
        }
        
        text((millis() - lastVibrationTime) / 1000.0, 10, displayHeight/2 + 30);
    } else {
        text("PRESS BUTTON TO START", 10, displayHeight/2);
    }
}

void sendLaundryDone()
{
    // put twitter api and stuff here
   
   /*Begin SendGrid api*/
   SendGrid sendgrid = new SendGrid("jackjamieson", "HacktcnJ14");

   sendgrid.addTo(USER_EMAIL);
   sendgrid.setFrom("LaundryMachine@tcnj.edu");
   sendgrid.setSubject("Laundry is done!");
   sendgrid.setText("Hey, just wanted to let you know that your laundry is done.\nBetter pick it up before someone else does.\n");
  
   sendgrid.send();
   
   println("SENT EMAIL");
   
   //

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
   
   println("SENT TWITTER MESSAGE");
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
    
            if(abs(xv) + abs(yv) + abs(zv) > SENSITIVITY) {
                lastVibrationTime = millis();
            }
        } catch(Exception e) {
            println("Exception cast on JSON stuff");
        }
    } else if(serialStr.substring(0,7).equals("[start]")) {
        running = true;
        lastVibrationTime = millis();
    } else {
        println(serialStr);
    }
}

