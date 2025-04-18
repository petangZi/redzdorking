#!/bin/bash

# ==================================================
# REDZDORKING v1 🚀 by KING REDZ 😈 9r3s1k
# All-in-One SQLi & Web Vuln Scanner via Dork + UI
# ==================================================

# ---------- 🎨 Warna ----------
RED='\\033[0;31m'
GREEN='\\033[0;32m'
YELLOW='\\033[1;33m'
BLUE='\\033[1;34m'
NC='\\033[0m' # No Color

# ---------- 📁 Buat folder hasil di storage ----------
RESULT_DIR="/storage/emulated/0/resultDorkredz"
mkdir -p $RESULT_DIR

# ---------- 🌐 Google Dork Search ----------
function google_dork() {
    echo -e "${YELLOW}[+] Masukkan Dork Google (cth: inurl:index.php?id=)${NC}"
    read -p "Dork: " dork
    echo -e "${BLUE}[!] Mencari target dari Google...${NC}"
    curl -s "https://www.google.com/search?q=${dork}&num=30" -A "Mozilla" | \
    grep -oP '(?<=/url\\?q=)(http.*?)(?=&)' | uniq > $RESULT_DIR/targets.txt
    echo -e "${GREEN}[✓] Ditemukan $(wc -l < $RESULT_DIR/targets.txt) target${NC}"
}

# ---------- 🔍 Scan Parameter URL ----------
function scan_params() {
    echo -e "${YELLOW}[+] Masukkan URL untuk scan parameter (cth: http://example.com/page.php?id=1)${NC}"
    read -p "URL Target: " url
    base=$(echo "$url" | cut -d'?' -f1)
    params=$(echo "$url" | cut -d'?' -f2 | tr '&' '\\n')
    
    for p in $params; do
        key=$(echo "$p" | cut -d'=' -f1)
        value=$(echo "$p" | cut -d'=' -f2)
        test_url="${base}?${key}=1337"
        sql_payload="${base}?${key}=1337'"
        
        # Basic check via curl
        normal=$(curl -s "$test_url")
        inj=$(curl -s "$sql_payload")
        
        if [[ "$inj" != "$normal" ]]; then
            echo -e "${RED}[VULN] $sql_payload${NC}"
            echo "[SQLi] $sql_payload" >> $RESULT_DIR/vuln.txt
        else
            echo -e "${BLUE}[-] $sql_payload -> aman${NC}"
        fi
    done
}

# ---------- 🔐 Bypass WAF (sederhana) ----------
function waf_bypass() {
    echo -e "${YELLOW}[!] Menjalankan payload WAF bypass...${NC}"
    # Bisa ditambah payload encode/obfuscate ke sini
}

# ---------- 🕵️‍♂️ Cek Kerentanan Umum di Web ----------
function vuln_check() {
    echo -e "${YELLOW}[+] Masukkan URL untuk cek kerentanannya (cth: http://example.com)${NC}"
    read -p "URL Target: " url
    resp=$(curl -s "$url")
    
    # Cek PHPInfo (kerentanan umum pada PHP)
    if echo "$resp" | grep -q "phpinfo"; then
        echo "[PHPINFO] $url" >> $RESULT_DIR/vuln.txt
        echo -e "${RED}[!] PHPInfo ditemukan di $url${NC}"
    fi

    # Cek Directory Listing (kerentanan di web statis atau PHP)
    if echo "$resp" | grep -q "Index of /"; then
        echo "[DIRLIST] $url" >> $RESULT_DIR/vuln.txt
        echo -e "${RED}[!] Directory Listing ditemukan di $url${NC}"
    fi

    # Cek XSS (Cross-Site Scripting)
    if echo "$resp" | grep -q "<script>"; then
        echo "[XSS] $url" >> $RESULT_DIR/vuln.txt
        echo -e "${RED}[!] XSS vulnerability ditemukan di $url${NC}"
    fi
    
    # Cek untuk LFI/RFI (Local File Inclusion / Remote File Inclusion)
    if echo "$resp" | grep -q "include" || echo "$resp" | grep -q "require"; then
        echo "[LFI/RFI] $url" >> $RESULT_DIR/vuln.txt
        echo -e "${RED}[!] LFI/RFI vulnerability ditemukan di $url${NC}"
    fi

    # Cek .git (GitHub repo yang tidak dikunci bisa jadi kerentanan)
    if curl -s "$url/.git" | grep -q "repository"; then
        echo "[GITINFO] $url" >> $RESULT_DIR/vuln.txt
        echo -e "${RED}[!] .git directory exposed di $url${NC}"
    fi
}

# ---------- 🧠 Menu Utama ----------
while true; do
    echo -e "\\n${BLUE}========= REDZDORKING v3.0 =========${NC}"
    echo -e "${GREEN}1. Cari target via Google Dork"
    echo -e "2. Scan parameter di URL"
    echo -e "3. Cek kerentanannya (PHPInfo, DirList, XSS, LFI/RFI, .git)"
    echo -e "4. Keluar${NC}"
    read -p "Pilih menu: " menu
    case $menu in
        1) google_dork;;
        2) scan_params;;
        3) vuln_check;;
        4) exit;;
        *) echo "Pilihan nggak valid!";;
    esac
    sleep 1
done
