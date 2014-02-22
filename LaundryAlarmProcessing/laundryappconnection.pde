void setup()
{
  ConfigurationBuilder cb = new ConfigurationBuilder();
  cb.setDebugEnabled(true);
  cb.setOAuthConsumerKey("1GJBae4bYerZgvywIuqoQ");
  cb.setOAuthConsumerSecret("1I3UfAiRUsfcy9J1FK1DYU8XHDOpcXnZrDE1uxmo");
  cb.setOAuthAccessToken("1280785147-Oe9vFIEJmWmq99Ohi44wFbMSzP1WS11chVAx9iM");
  cb.setOAuthAccessTokenSecret("FnVC5R3Dhjvixp4zZmykdF4a0z7AApuwklTrap71eEOlt");
  TwitterFactory builder = new TwitterFactory(cb.build());
  Twitter twitter=builder.getInstance();
  UsersResources userres = twitter.users();
  try
  {
  User user = userres.showUser("SeanSafari");
 
  DirectMessage message = twitter.sendDirectMessage(user.getId(), "Laundry is done, figga");

  
  }
  catch(Exception e)
  {
    println(e);
  }

}

