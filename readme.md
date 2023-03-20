##  Jitsi on Ubuntu 22.04 with an Azure ARM Template

When Zoom became a household word in the early days of the Covid-19 pandemic, it was plagued with security issues. Despite this, organizations and schools adopted Zoom as the application for hosting online meetings. Still, it left many wondering, “Is there a more secure way to host online meetings without Zoom or other apps like it?” Zoom was one of many other apps from Big Tech, like Google Meets, Microsoft Teams, Facetime, and Facebook Messenger.  Even though these apps were generally more secure, they still left people wanting better control over privacy. Fortunately, it’s not only possible. It’s quite easy to do with an Azure VM and a little open-source app called Jitsi, which gives you a secure place to host meetings without any of the privacy concerns of Big Tech.

Setting up Jitsi on Azure is straightforward if you want to copy and paste a bunch of commands into a Ubuntu machine terminal. There are a ton of guides on how to do this, but I figured I would just automate it the process. You can click the link below, fill out a form, and deploy your instance of Jitsi to an Azure VM. Once there, you can use a browser or a mobile app to create or connect to meetings. It’s that easy.

If you want to use the install script off Azure, it’s pretty simple, too. Download the script and run it on an Ubuntu 22.04 VM on any other cloud or on-premise if you want to do that. You’ll need an FQDN for the VM’s public IP and the following ports on the firewall open: TCP/22, TCP/80, TCP/443, UDP/3478, TCP/5349, and UDP/10000

```
wget https://raw.githubusercontent.com/theonemule/jitsi-install/main/install.sh

bash install.sh --hostname=jitsi3.eastus.cloudapp.azure.com --username=youruser --password=yourpassword --email=you@example.com

```

The parameters are pretty easy:

* hostname – use the hostname for your IP address. The script uses Let’s Encrypt to generate an SSL Certificate for the connection and the web UI.
* username – the user name needed to create rooms on the server once it’s instlled.
* password – the password used to authenticate the user to create rooms
* email – the email used or Let’s Encrypt.

The script downloads and configures all of the components for Jitsi. Once you’re operational, you should be able to point your browser to https://hostname and create a room.

You can get the [iOS client here](https://apps.apple.com/us/app/jitsi-meet/id1165103905) and the [Android client here](https://play.google.com/store/apps/details?id=org.jitsi.meet&hl=en_US&gl=US).

In the app, past in the name of the room you created, and you should be able to join the conference.



