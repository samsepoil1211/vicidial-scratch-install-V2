# vicidial-scratch-install-V2
V2 tutorial to install vicidial from scratch on Alma Linux 9 with asterisk 18
<hr>

<p>Follow the instruction given in the txt file. Just use your brain and some copy paste skill. Don't do it <br> blindly.</p>
<hr>
<p>Note :- change line no. 90 from your.own.domain to the original domain you are using and have authority. For ssl/tls,<br>you can use custom ssl or use let's excrypt ssl.</p>
<hr>
<p> <b>One more thing, if you want the ssh public access to be with password authinticated, then follow this</b> :- <br> 
1. sudo sed -i 's/^PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config /etc/ssh/sshd_config.d/*.conf 2>/dev/null; <br>
2. sudo systemctl restart sshd
