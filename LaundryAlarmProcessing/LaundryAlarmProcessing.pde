import org.json.JSONObject;
import processing.serial.*;
import com.github.sendgrid.SendGrid;


final static String USER_EMAIL = "shoffing@gmail.com";
final static String USER_PHONE = "6093542426";
final static String USER_TWITTER = "shoffing";

final static int SENSITIVITY = 400;

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
   sendgrid.setFrom("laundryMachine@tcnj.edu");
   sendgrid.setSubject("Laundry is done!");
   sendgrid.setText("Hey, just wanted to let you know that your laundry is done.\nBetter pick it up before someone else does.\n");
  
   sendgrid.send();
   
   println("SENT EMAIL");
   
   //
   
   ConfigurationBuilder cb = new ConfigurationBuilder();
   cb.setDebugEnabled(true);
   cb.setOAuthConsumerKey("1GJBae4bYerZgvywIuqoQ");
   cb.setOAuthConsumerSecret("1I3UfAiRUsfcy9J1FK1DYU8XHDOpcXnZrDE1uxmo");
   cb.setOAuthAccessToken("1280785147-Oe9vFIEJmWmq99Ohi44wFbMSzP1WS11chVAx9iM");
   cb.setOAuthAccessTokenSecret("FnVC5R3Dhjvixp4zZmykdF4a0z7AApuwklTrap71eEOlt");
   Date dNow = new Date( );
   SimpleDateFormat ft = new SimpleDateFormat ("E yyyy.MM.dd 'at' hh:mm:ss a zzz");

   TwitterFactory builder = new TwitterFactory(cb.build());
   Twitter twitter=builder.getInstance();
   UsersResources userres = twitter.users();
   try {
       User user = userres.showUser(USER_TWITTER);
       StatusUpdate latestStatus = new StatusUpdate("@" + USER_TWITTER + " Laundry is done! (" + ft + ")");
       Status status = twitter.updateStatus(latestStatus);
      // DirectMessage message = twitter.sendDirectMessage(user.getId(), "Laundry is done, figga");
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

