![Twitterline](http://users.irq6.net/~/lytchi/twitterline.png)

This little script is using the Twitter OAuth 1.0 and the user streaming API and display in the shell everytime you hit enter. The tweets are spooled in a temporary file (/tmp/.twitter). That's not a big thing but I still using it.

Do not forget to add this on your ~/.bashrc.

```
PROMPT_COMMAND='if [ -s /tmp/.twitter ]; then
echo -e "$(head -n 1 /tmp/.twitter; echo; perl -ni -e "print unless $. == 1" /tmp/.twitter)"
fi'
```

If you want to use this script, you need to generate and export the required tokens for the Twitter OAuth 1.0, the documentation can be found here: https://dev.twitter.com/oauth/overview/application-owner-access-tokens.

Eg: export CONSUMER_KEY='abcefgh'  
    export CONSUMER_SECRET='ijklmop'  
    export TOKEN_KEY='1321414-qwerty'  
    export TOKEN_SECRET='asdfghj'  

If the variables are not set, or partially, the behavior is undefined.

Emojis are not currently supported. Todo: Need a regex to clean this mess.   
Todo: Add the tweet in PS2 ?   
Todo: Rewrite this in an other language. Perl or python.  

