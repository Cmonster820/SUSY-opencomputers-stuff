# SUSY-opencomputers-stuff

This is all my stuff that I programmed for my SUSY bases

To use this for your own bases, you should only have to paste the program into a computer (insert or middle click while a .lua file is open) and run the file, but to change the list of allowed cards on the mainframe, you must change the "Cards" table to contain the data on every accepted card, separated by commas, do note that you may have to reprogram the mainframe a little bit in order to have a blacklist instead of a whitelist

If you, for some reason, want to add to my internet of spaghetti code, the template for automatic router negotiation is the file titled "Ahh yes, the negotiator," with the 2 types of name settings commented out, this is a copy of the access controller node script, so if I forgot to remove some ACS stuff please open an issue

DEPLOYMENT ORDER FOR SECURITY STUFF

    1. Router, this is required to route information between the different computers, even if you aren't using the security stuff, this is still required first.
    2. Mainframe, this processes all information from the security nodes, note that this requires a tier 3 data card, I typically put this in a rack
    3. Ping Server, this is technically not required but I don't really know how to make a prompt to disable this, this pings every security node, barring the mainframe and other frames, every 20 seconds and if there are insufficient replies 3 times in a row (will occur if a node is destroyed), then it triggers a lockdown
    4. Everything Else, in other words, I'm writing this when I only have access control nodes and I don't know If I'm going to add anything else