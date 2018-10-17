#!/bin/bash

defaultInstall() {
	echo "  - *** Fivem user and group ***"
	useradd -d /home/fivem -m -r -s /bin/bash -U fivem
	if [ -e /home/fivem/fx.tar.xz ]; then
		echo "  - fx.tar.xz Already exists"
		rm -fr /home/fivem/fx.tar.xz
	fi

	echo "  - *** Fivem Download ***"
	fvDlUrl="https://runtime.fivem.net/artifacts/fivem/build_proot_linux/master/807-a33d6db066568046a9a99b14b0fccb03bb978e2f/fx.tar.xz"
	wget -nv -q --show-progress $fvDlUrl -O /home/fivem/fx.tar.xz
	cd /home/fivem
	tar xfJ fx.tar.xz
	wget https://raw.githubusercontent.com/Artnod-FiveM-Mods/Server-cloud-init/master/start.sh -O /home/fivem/start.sh
	wget https://raw.githubusercontent.com/Artnod-FiveM-Mods/Server-cloud-init/master/stop.sh -O /home/fivem/stop.sh
	wget https://raw.githubusercontent.com/Artnod-FiveM-Mods/Server-cloud-init/master/fivem.service -O /etc/systemd/system/fivem.service

	echo "  - Fivem public server-data"
	git clone https://github.com/citizenfx/cfx-server-data.git /home/fivem/server-data

	echo "  - Fivem Change Policies"
	chown -R fivem:fivem /home/fivem/
	chmod -R 0775 /home/fivem/
	chown root.root /etc/systemd/system/fivem.service
	chmod 0777 /etc/systemd/system/fivem.service
	
	echo "  - FiveM Create deamon"
	systemctl enable fivem.service
	
	echo "  - Script ended successfully. You can now:"
	echo "    - Add /home/fivem/server-data/server.cfg"
	echo "    - Add resources in /home/fivem/server-data/resources/"
}

customInstall() {
	echo "  - *** Custon Init ***"
	cp /etc/ssh/ssh_host_rsa_key /root/.ssh/id_rsa
	cp /etc/ssh/ssh_host_rsa_key.pub /root/.ssh/id_rsa.pub
	ssh-keygen -F github.com || ssh-keyscan github.com >> /root/.ssh/known_hosts
	git config --global user.name "artnod78"
	git config --global user.mail "artnod78@gmail.com"
	
	echo "  - *** Clone Custom repo ***"
	git clone git@github.com:artnod78/Fivem-Server.git /root/fmm
	
	echo "  - *** Exec Custom Script ***"
	sed -i -e 's/\r$//' /root/fmm/update.sh
	chmod +x /root/fmm/update.sh
	sed -i -e 's/\r$//' /root/fmm/bootstrapTest.sh
	chmod +x /root/fmm/bootstrapTest.sh
	/root/fmm/bootstrapTest.sh -i
}

main() {
	if [ $RUNINSTALL -eq 1 ]; then
		defaultInstall
	fi
	if [ $CUSTOMINSTALL -eq 1 ]; then
		customInstall
	fi
}

if [ -z $1 ]; then
	echo "  - https://github.com/Artnod-FiveM-Mods/Server-cloud-init"
	exit 0
fi

while getopts "hic" opt; do
	case "$opt" in
		h)
			echo "  - https://github.com/Artnod-FiveM-Mods/Server-cloud-init"
			exit 0
			;;
		i)
			RUNINSTALL=1
			;;
		c)
			CUSTOMINSTALL=1
			;;
	esac
done
main
