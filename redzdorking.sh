#!/bin/bash

# REDZDORKING v1 UI BY KING REDZ 😈
# ==============================
# Full SQLI + PARAM SCAN + VULN CHECK
# SAVE TO /storage/emulated/0/resultDorkredz
# ==============================

# 🎨 Warna-warni gengs
RED='\033[0;31m'
GREEN='\033[1;32m'
YELLOW='\033[1;33m'
BLUE='\033[1;36m'
NC='\033[0m'

# Banner Keren
function banner() {
clear
echo -e "${RED}"
echo "/  |      /  |                                                    /  |          
$$ |   __ $$/  _______    ______          ______    ______    ____$$ | ________ 
$$ |  /  |/  |/       \  /      \        /      \  /      \  /    $$ |/        |
$$ |_/$$/ $$ |$$$$$$$  |/$$$$$$  |      /$$$$$$  |/$$$$$$  |/$$$$$$$ |$$$$$$$$/ 
$$   $$<  $$ |$$ |  $$ |$$ |  $$ |      $$ |  $$/ $$    $$ |$$ |  $$ |  /  $$/  
$$$$$$  \ $$ |$$ |  $$ |$$ \__$$ |      $$ |      $$$$$$$$/ $$ \__$$ | /$$$$/__ 
$$ | $$  |$$ |$$ |  $$ |$$    $$ |      $$ |      $$       |$$    $$ |/$$      |
$$/   $$/ $$/ $$/   $$/  $$$$$$$ |      $$/        $$$$$$$/  $$$$$$$/ $$$$$$$$/ 
                        /  \__$$ |                                              
                        $$    $$/                                               
                         $$$$$$/                                  ";
          
echo -e "${YELLOW}=================[ BY KING REDZ 😈 ]=================${NC}"
echo -e "${GREEN} 🔥 SQLI • PARAM SCAN • VULN CHECK • DORK API 🔥${NC}"
}

# 📁 Buat folder hasil
RESULT_DIR="/storage/emulated/0/resultDorkredz"
mkdir -p $RESULT_DIR

# Loader efek
function loader() {
    echo -ne "${BLUE}⏳ Loading"
    for i in {1..5}; do
        echo -n "."
        sleep 0.3
    done
    echo -e "${NC}"
}

# 🌐 Google Dork Search
function google_dork() {
    banner
    echo -e "${YELLOW}[+] Masukkan Google Dork (cth: inurl:index.php?id=)${NC}"
    read -p "Dork: " dork
    echo -e "${BLUE}[!] Mencari target dari Google...${NC}"
    loader
    curl -s "https://www.google.com/search?q=${dork}&num=30" -A "Mozilla" | \
    grep -oP '(?<=/url\\?q=)(http.*?)(?=&)' | uniq > $RESULT_DIR/targets.txt
    echo -e "${GREEN}[✓] Target tersimpan: $RESULT_DIR/targets.txt${NC}"
}

# 🔍 Scan Parameter
function scan_params() {
    banner
    echo -e "${YELLOW}[+] Masukkan URL Target dengan parameter (cth: http://site.com/index.php?id=1)${NC}"
    read -p "URL Target: " url
    base=$(echo "$url" | cut -d'?' -f1)
    params=$(echo "$url" | cut -d'?' -f2 | tr '&' '\n')

    echo -e "${BLUE}[!] Scan dimulai...${NC}"
    loader

    for p in $params; do
        key=$(echo "$p" | cut -d'=' -f1)
        sql_url="${base}?${key}=1'"
        normal=$(curl -s "$base?${key}=1")
        inj=$(curl -s "$sql_url")
        if [[ "$inj" != "$normal" ]]; then
            echo -e "${RED}[VULN] ${sql_url}${NC}"
            echo "[SQLi] $sql_url" >> $RESULT_DIR/vuln.txt
        else
            echo -e "${GREEN}[OK] ${sql_url}${NC}"
        fi
    done
    echo -e "${GREEN}[✓] Hasil disimpan di: $RESULT_DIR/vuln.txt${NC}"
}

# 🕵️‍♂️ Cek Kerentanan
function vuln_check() {
    banner
    echo -e "${YELLOW}[+] Masukkan URL target (cth: http://example.com)${NC}"
    read -p "URL Target: " url
    loader
    resp=$(curl -s "$url")

    echo -e "${BLUE}Hasil Pengecekan:${NC}"
    if echo "$resp" | grep -q "phpinfo"; then
        echo -e "${RED}[!] PHPInfo ditemukan!${NC}"
        echo "[PHPINFO] $url" >> $RESULT_DIR/vuln.txt
    fi
    if echo "$resp" | grep -q "Index of /"; then
        echo -e "${RED}[!] Directory Listing aktif!${NC}"
        echo "[DIRLIST] $url" >> $RESULT_DIR/vuln.txt
    fi
    if echo "$resp" | grep -q "<script>"; then
        echo -e "${RED}[!] Kemungkinan XSS!${NC}"
        echo "[XSS] $url" >> $RESULT_DIR/vuln.txt
    fi
    if echo "$resp" | grep -q "include" || echo "$resp" | grep -q "require"; then
        echo -e "${RED}[!] Potensi LFI/RFI!${NC}"
        echo "[LFI/RFI] $url" >> $RESULT_DIR/vuln.txt
    fi
    if curl -s "$url/.git" | grep -q "repository"; then
        echo -e "${RED}[!] .git directory terbuka!${NC}"
        echo "[GITINFO] $url" >> $RESULT_DIR/vuln.txt
    fi
    echo -e "${GREEN}[✓] Scan selesai, cek file: $RESULT_DIR/vuln.txt${NC}"
}

# 🎛️ Menu
while true; do
    banner
    echo -e "${GREEN} 1. Cari Target via Google Dork"
    echo " 2. Scan Parameter SQL Injection"
    echo " 3. Cek Kerentanan Web"
    echo -e " 4. Keluar${NC}"
    echo -ne "${YELLOW}Pilih menu >> ${NC}"
    read menu
    case $menu in
        1) google_dork ;;
        2) scan_params ;;
        3) vuln_check ;;
        4) echo -e "${RED}Keluar...${NC}"; break ;;
        *) echo -e "${RED}[!] Pilihan nggak valid bro.${NC}" ;;
    esac
    echo ""
    read -p "Tekan Enter buat lanjut..."
done
