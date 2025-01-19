# WWB-COM_Tools

--- Introduction ---

This project is intented to provide some basic testing scripts to leverage when performing penetration testing, purple teaming, or self assessment of legacy applicaitons that have native WWB-COM scripting capability. WWB-COM is a flavor of basic that you can test and develop for using WinWrap, which is also embeded in multiple applications and products including IBM SPSS, among others. It is organized into phases of an attack lifecycle according to where the scripts may be useful. Note that phases of a typical penetration test engagement where WWB-COM would not be likely to be useful have been omitted. Basically, this project is focused on testing the abuse of WWB-COM for initial access, persistence, and defense evasion since this is where the innate capabilities of exposed legacy scripting of this nature are likely to be useful.  

My intention with this effort was to create basic scripts for testing that demonstrate how exposed WWB-COM scripting capabilities could provide capabilities such as:
 - The ability to execute a payload that would connect to a remote listener and execute commands.
 - Other ways to create an initial foothold, such as simply launching an application directly, in the context of escape to host via presented app.
 - Defense evasion, via a hostfile entry targeted to blind <some> AV via DNS.
 - Persistence scripts via Scheduled Tasks, Adding User Accounts, and Run regkey.

The idea here is not to be exhastive, but to provide enough to work with to rapidly test and see if you have a problem.  That said, if people who work full time doing red team work want to take this and build upon it, it can certainly be made better (very primitive now), which of course only makes sense if the scenario that caused me to work on this is widespread.  

So, what is the scenario that caused me to start working on this?  

While working on testing a series of excape to host flaws involving movement from presented apps to the server hosting them, I noticed some apps such as IBM SPSS (and other statistics programs), provide the ability to use scripts against data sets via a basic flavor called WWB-COM (WinWrap). The research question was, if a script run in the context of a remote lower privilege user, could it escape the host by executing that code on the server hosting the app, esatablishing a shell or remote command execution. These scripts, while inglorious, should provide more than enough to validate if that is possible for such a sceanrio.  

An intersting side note, is that escape-to-host via presented app, using a legacy flavor like WWB-COM seems to be at least somewhat evasive. Initial testing revealed an ability to bypass at least a couple AV/EDR products.  Further testing in this area may be intersting, although the scope of this excact scenario may be limited (presented app + app presented has WWB-COM capability).  

This attack vector also may be worth considering from a user perspective, even for organizations without a WWB-COM capable app being presented via an application delivery server. For example, if an adversary is attacking a research-oriented company where a key user demographic is likely to have a software such as SPSS, social engineering along with a carefully delivered payload could lead to compromise (I did not replicate this scenario, but it seems plausable). 

--- Ethical Standards / Code of Conduct ---

This project has been started to help better test our products, configurations, detection engineering, and overall security posture. We can only be successful at properly defending against evasive tactics, if we have the tools and resources to replicate the types of approaches being used by adversaries in an effective manner. Participation in this project and/or use of these tools implies good intent to use these tools ethically to help better protect/defend, as well as an intent to follow all applicable laws and standards associated with the industry.

--- How to Contribute ---

We welcome and encourage contributions, participation, and feedback - as long as all participation is legal and ethical in nature. Please develop new scripts, contribute ideas, improve the scripts that we have created. The goal of this project is to come up with a robust testing framework that is available to red/blue/purple teams for assessment purposes, with the hope that one day we can archive this project because improvements to detection logic make this attack vector irrelevant.

1. Fork the project
2. Create your feature branch (git checkout -b feature/AmazingFeature)
3. Commit your changes (git commit -m 'Add some AmazingFeature')
4. Push to the branch (git push origin feature/AmazingFeature)
5. Open a Pull Request
   
--- Acknowledgments ---

A few researchers directly contributed, either to this project or to the testing that led to it:
 - christian-taillon
 - Duncan4264
 - flawdC0de
 - Kitsune-Sec
 - shammahwoods

A few scripts were also adapted from BypassIT contributions by AnuraTheAmphibian (usually mentioned in the comments), as well as from other contributors mentioned above.  
 


